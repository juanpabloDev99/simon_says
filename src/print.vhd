library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity print is
    generic (
        CLOCK_FREQ       : integer := 125_000_000;
        PRINT_SECONDS    : integer range 0 to 15 := 2;
        WAIT_FRACTION    : integer range 0 to 15 := 4;
        SENTENCE_SECONDS : integer range 0 to 15 := 10;
        KEEP_CYCLES      : integer range 0 to 15 := 15);
	port(
		clk, reset, clear : IN std_logic;
		status            : IN std_logic_vector(2 downto 0); -- 001 is sequence printing, 010 is win, 011 is loose; 101 is playing, 000 is void
		buttons           : IN std_logic_vector(3 downto 0);
		round             : IN unsigned(2 downto 0);
		random            : IN std_logic_vector(15 downto 0);
		segments          : OUT std_logic_vector(6 downto 0);
        selector          : OUT std_logic_vector(3 downto 0);
		done              : OUT std_logic);
end print;

architecture Behavioral of print is
    component buttonsPrint
        generic (KEEP_CYCLES : integer range 0 to 15);
        port ( 
            clk, reset, clear : IN  std_logic;
            buttons           : IN  std_logic_vector(3 downto 0);
            output            : OUT  std_logic_vector(3 downto 0);
            finished          : OUT std_logic);
    end component;

    component lights
        generic(
            CLOCK_FREQ       : integer;
            PRINT_SECONDS    : integer range 0 to 15;
            WAIT_FRACTION    : integer range 0 to 15;
            SENTENCE_SECONDS : integer range 0 to 15 := 10);
        port(
            clk, reset, clear : IN std_logic;
            status            : IN std_logic_vector(1 downto 0); -- 001 is sequence printing, 010 is win, 011 is loose
            round             : IN unsigned(2 downto 0);
            randomSequence    : IN std_logic_vector(15 downto 0);
            selector          : OUT std_logic_vector(3 downto 0);
            finished          : OUT std_logic);
    end component;

    component decoder
        port (
            control  : IN std_logic_vector(1 downto 0);
            segments : OUT std_logic_vector(6 downto 0));
    end component;

    signal butt_selector, light_selector : std_logic_vector(3 downto 0) := "0000";
    signal light_clear, buttons_clear    : std_logic := '0';
    signal light_done, buttons_done      : std_logic := '0';
begin
--    u_buttons : buttonsPrint
--    generic map(KEEP_CYCLES => KEEP_CYCLES)
--    port map(
--        clk      => clk,
--        reset    => reset,
--        clear    => buttons_clear,
--        buttons  => buttons,
--        output   => butt_selector,
--        finished => buttons_done);

    u_lights : lights
    generic map(
        CLOCK_FREQ       => CLOCK_FREQ,
        PRINT_SECONDS    => PRINT_SECONDS,
        WAIT_FRACTION    => WAIT_FRACTION,
        SENTENCE_SECONDS => SENTENCE_SECONDS)
    port map(
        clk            => clk,
        reset          => reset,
        clear          => light_clear,
        status         => status(1 downto 0),
        round          => round,
        randomSequence => random,
        selector       => light_selector,
        finished       => light_done);

    u_decoder : decoder
    port map(
        control  => status(1 downto 0),
        segments => segments);

    selector <= "0000" when status = "000" OR clear = '1' else
--                butt_selector when status = "101" else
                light_selector when status(2) = '0' else
                "0000";
    done <= '0' when status = "000" else
--            buttons_done when status = "101" else
            light_done when status(2) = '0' else
            '0';

    light_clear <= '1' when status = "000" OR status = "101" OR clear = '1' else
                   '0';
--    buttons_clear <= '1' when status /= "101" OR clear = '1' else
--                     '0';
end;