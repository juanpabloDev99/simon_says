library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity lights is
    generic (
        CLOCK_FREQ       : integer := 125_000_000;
        PRINT_SECONDS    : integer range 0 to 15 := 2;
        WAIT_FRACTION    : integer range 0 to 15 := 4;
        SENTENCE_SECONDS : integer range 0 to 15 := 10);
	port(
		clk, reset, clear : IN std_logic;
        status            : IN std_logic_vector(1 downto 0); -- 01 is sequence printing, 10 is win, 11 is loose
		round             : IN unsigned(2 downto 0);
		randomSequence    : IN std_logic_vector(15 downto 0);
        selector          : OUT std_logic_vector(3 downto 0);
		finished          : OUT std_logic);
end lights;

architecture Behavioural of lights is
    type STATE_TYPE is (IDLE, PRINT_SEQ, WAIT_SEQ, PRINT_SENT, DONE);

    component timer
        generic (
            CLOCK_FREQ : integer;
            SECONDS    : integer range 0 to 15);
        port (
            clk, reset, clear : IN std_logic;
            expired           : OUT std_logic);
    end component;

    component selectWord
        port (
            counter  : IN unsigned(2 downto 0);
            sequence : IN std_logic_vector(15 downto 0);
            word     : OUT std_logic_vector(3 downto 0)
        );
    end component;

    signal counter, saved_round             : unsigned(2 downto 0) := (OTHERS => '0');
    signal print_expired, print_clear       : std_logic := '0';
    signal wait_expired, wait_clear         : std_logic := '0';
    signal sentence_expired, sentence_clear : std_logic := '0';
    signal current_state                    : STATE_TYPE := IDLE;
    signal word                             : std_logic_vector(3 downto 0);
begin
    print_timer : timer
        generic map (
            CLOCK_FREQ => CLOCK_FREQ,
            SECONDS    => PRINT_SECONDS)
        port map (
            clk     => clk,
            reset   => reset,
            clear   => print_clear,
            expired => print_expired
        );

    wait_timer : timer 
        generic map (
            CLOCK_FREQ => CLOCK_FREQ / WAIT_FRACTION,
            SECONDS => PRINT_SECONDS)
        port map(
            clk => clk,
            reset => reset,
            clear   => wait_clear,
            expired => wait_expired
        );

    sentence_timer : timer 
        generic map (
            CLOCK_FREQ => CLOCK_FREQ,
            SECONDS => SENTENCE_SECONDS)
        port map(
            clk => clk,
            reset => reset,
            clear   => sentence_clear,
            expired => sentence_expired
        );

    u_word: selectWord
        port map (
            counter  => counter,
            sequence => randomSequence,
            word     => word
        );

    process(reset, clk)
    begin
        if reset = '1' then
            selector <= (OTHERS => '0');
            counter <= (OTHERS => '0');
            current_state <= IDLE;
            saved_round <= round;
            sentence_clear <= '1';
            wait_clear <= '1';
            print_clear <= '1';
        elsif rising_edge(clk) then
            if clear = '1' then
                selector <= (OTHERS => '0');
                counter <= (OTHERS => '0');
                current_state <= IDLE;
                saved_round <= round;
                sentence_clear <= '1';
                wait_clear <= '1';
                print_clear <= '1';
            elsif current_state = IDLE and status = "01" then
                current_state <= PRINT_SEQ;
                print_clear <= '0';
                selector <= word;
            elsif current_state = IDLE and status(1) = '1' then
                current_state <= PRINT_SENT;
                sentence_clear <= '0';
                selector <= (OTHERS => '1');
            elsif current_state = PRINT_SEQ and print_expired = '1' then
                selector <= (OTHERS => '0');
                if counter = saved_round then
                    current_state <= DONE;
                    sentence_clear <= '1';
                    wait_clear <= '1';
                    print_clear <= '1';
                else
                    counter <= counter + 1;
                    current_state <= WAIT_SEQ;
                    print_clear <= '1';
                    wait_clear <= '0';
                end if;
            elsif current_state = WAIT_SEQ and wait_expired = '1' then
                current_state <= PRINT_SEQ;
                print_clear <= '0';
                wait_clear <= '1';
                selector <= word;
            elsif current_state = PRINT_SENT and sentence_expired = '1' then
                current_state <= DONE;
                sentence_clear <= '1';
                wait_clear <= '1';
                print_clear <= '1';
                selector <= (OTHERS => '0');
            end if;
        end if;
    end process;

    finished <= '1' when current_state = DONE else '0';
end Behavioural;