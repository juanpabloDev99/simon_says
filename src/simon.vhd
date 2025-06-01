library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simon is
    generic(
        CLOCK_FREQ       : integer := 125_000_000;
        GAME_SECONDS     : integer range 0 to 15 := 2;
        PRINT_SECONDS    : integer range 0 to 15 := 1;
        WAIT_FRACTION    : integer range 0 to 15 := 4;
        SENTENCE_SECONDS : integer range 0 to 15 := 10;
        KEEP_CYCLES      : integer range 0 to 15 := 15;
        DEBOUNCE_CONTROL : integer range 0 to 15 := 15;
        SEED             : std_logic_vector(15 downto 0) := x"ABCD");
    port(
        clk, reset : IN std_logic;
        botones    : IN std_logic_vector(3 downto 0);
        leds       : OUT std_logic_vector(7 downto 0);
        segments   : OUT std_logic_vector(6 downto 0);
        selector   : OUT std_logic_vector(3 downto 0));
end simon;

architecture Behavioral of simon is
    constant STATUS_VOID       : std_logic_vector(2 downto 0) := "000";
    constant STATUS_WIN        : std_logic_vector(2 downto 0) := "010";
    constant STATUS_LOOSE      : std_logic_vector(2 downto 0) := "011";
    constant STATUS_PRINT      : std_logic_vector(2 downto 0) := "001";
    constant STATUS_GAME       : std_logic_vector(2 downto 0) := "101";
    constant STATUS_GAME_PRINT : std_logic_vector(2 downto 0) := "100";

    component game
        generic (
            CLOCK_FREQ   : integer;
            GAME_SECONDS : integer range 0 to 15);
        port(
            clk, reset, clear : IN std_logic;
            buttons           : IN std_logic_vector(3 downto 0);
            round             : IN unsigned(2 downto 0);
            random            : IN std_logic_vector(15 downto 0);
            done, error       : OUT std_logic);
    end component;

    component print
    generic (
        CLOCK_FREQ       : integer;
        PRINT_SECONDS    : integer range 0 to 15;
        WAIT_FRACTION    : integer range 0 to 15;
        SENTENCE_SECONDS : integer range 0 to 15 := 10;
        KEEP_CYCLES      : integer range 0 to 15);
	port(
		clk, reset, clear : IN std_logic;
		status            : IN std_logic_vector(2 downto 0); -- 001 is sequence printing, 010 is win, 011 is loose; 101 is playing, 000 is void
		buttons           : IN std_logic_vector(3 downto 0);
		round             : IN unsigned(2 downto 0);
		random            : IN std_logic_vector(15 downto 0);
		segments          : OUT std_logic_vector(6 downto 0);
        selector          : OUT std_logic_vector(3 downto 0);
		done              : OUT std_logic);
	end component;

    component random
    generic(SEED : std_logic_vector(15 downto 0));
    port (
        clk, reset, clear, enable : IN  std_logic;
        sequence                  : OUT std_logic_vector(15 downto 0));
    end component;

    component buttonsInterface
    generic(DEBOUNCE_CONTROL : integer range 0 to 15);
    port (
        clk, reset : IN std_logic;
        buttons    : IN std_logic_vector(3 downto 0);
        outputs    : OUT std_logic_vector(3 downto 0));
    end component;

    signal status                  : std_logic_vector(2 downto 0) := STATUS_VOID;
    signal print_clear, game_clear : std_logic := '0';
    signal round                   : unsigned(2 downto 0) := "000";
    signal random_sequence         : std_logic_vector(15 downto 0) := (OTHERS => '0');
    signal game_output             : std_logic_vector(1 downto 0) := "00"; -- 01 is good, 10 is bad
    signal print_output            : std_logic := '0';
    signal seq_enable, seq_clear   : std_logic := '0';
    signal filtered_buttons        : std_logic_vector(3 downto 0) := "0000";
    signal corrected_buttons       : std_logic_vector(3 downto 0) := "0000";
begin
    u_buttons : buttonsInterface
    generic map(DEBOUNCE_CONTROL => DEBOUNCE_CONTROL)
    port map(
        clk     => clk,
        reset   => reset,
        buttons => filtered_buttons,
        outputs => corrected_buttons);

    u_game: game
        generic map (
            CLOCK_FREQ   => CLOCK_FREQ,
            GAME_SECONDS => GAME_SECONDS)
        port map(
            clk     => clk,
            reset   => reset,
            clear   => game_clear,
            buttons => corrected_buttons,
            round   => round,
            random  => random_sequence,
            done    => game_output(0),
            error   => game_output(1));

    u_print : print
        generic map (
            CLOCK_FREQ       => CLOCK_FREQ,
            PRINT_SECONDS    => PRINT_SECONDS,
            WAIT_FRACTION    => WAIT_FRACTION,
            SENTENCE_SECONDS => SENTENCE_SECONDS,
            KEEP_CYCLES      => KEEP_CYCLES)
        port map(
            clk      => clk,
            reset    => reset,
            clear    => print_clear,
            status   => status,
            buttons  => corrected_buttons,
            round    => round,
            random   => random_sequence,
            segments => segments,
            selector => selector,
            done     => print_output);

    u_random : random
        generic map(SEED => SEED)
        port map(
            clk      => clk,
            reset    => reset,
            clear    => seq_clear,
            enable   => seq_enable,
            sequence => random_sequence);

    seq_enable <= '1' when status = STATUS_VOID else
                  '0';

    leds <= "10000000" when round = "000" else
            "01000000" when round = "001" else
            "00100000" when round = "010" else
            "00010000" when round = "011" else
            "00001000" when round = "100" else
            "00000100" when round = "101" else
            "00000010" when round = "110" else
            "00000001";

    filtered_buttons <= botones when status = STATUS_VOID else
                        botones when status = STATUS_GAME else
                        "0000";

    process(reset, clk)
    begin
        if reset = '1' then
            status <= STATUS_VOID;
            round <= (OTHERS => '0');
            print_clear <= '1';
            game_clear <= '1';
            seq_clear <= '1';
        elsif rising_edge(clk) then
            if status = STATUS_VOID and corrected_buttons /= "0000" then
                status <= STATUS_PRINT;
            elsif status = STATUS_PRINT and print_output = '1' then
                status <= STATUS_GAME;
                print_clear <= '1';
                game_clear <= '0';
            elsif status = STATUS_GAME and game_clear = '1' then
                game_clear <= '0';
            elsif status = STATUS_GAME and game_output = "10" then -- bad done :(
                status <= STATUS_LOOSE;
                game_clear <= '1';
            elsif status = STATUS_GAME and game_output = "01" then -- well done :)
                if round = "111" then
                    status <= STATUS_WIN;
                else
                    status <= STATUS_PRINT;
                    round <= round + 1;
                    game_clear <= '1';
                end if;
            elsif (status = STATUS_PRINT or status = STATUS_LOOSE or status = STATUS_WIN) and print_clear = '1' then
                print_clear <= '0';
            elsif status = STATUS_LOOSE or status = STATUS_WIN then
                if print_output = '1' then
                    status <= STATUS_VOID;
                    print_clear <= '1';
                    game_clear <= '1';
                    seq_clear <= '1';
                    round <= (OTHERS => '0');
                end if;
            else
                seq_clear <= '0';
            end if;
        end if;
    end process;
end Behavioral;
