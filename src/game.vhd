library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity game is
    generic (
        CLOCK_FREQ   : integer := 125_000_000;
        GAME_SECONDS : integer range 0 to 15 := 2);
	port(
		clk, reset, clear  : IN std_logic;
		buttons            : IN std_logic_vector(3 downto 0);
		round              : IN unsigned(2 downto 0);
		random             : IN std_logic_vector(15 downto 0);
		done, error        : OUT std_logic);
end game;

architecture Behavioural of game is
    component timer
        generic (
            CLOCK_FREQ : integer;
            SECONDS    : integer range 0 to 15);
        port (
            clk, reset, clear : IN std_logic;
            expired           : OUT std_logic);
    end component;

    component singleButtonGame
        port(
            clk, reset, clear, timer : IN std_logic;
            buttons, word            : IN std_logic_vector(3 downto 0);
            done, error              : OUT std_logic);
	end component;

	component selectWord
        port (
            counter  : IN unsigned(2 downto 0);
            sequence : IN std_logic_vector(15 downto 0);
            word     : OUT std_logic_vector(3 downto 0));
    end component;

    signal word                : std_logic_vector(3 downto 0) := "0000";
    signal buttonOutput        : std_logic_vector(1 downto 0) := "00";
    signal pulseClear, expired : std_logic := '0';
    signal counter             : unsigned(2 downto 0) := "000";
    signal reachedLimit        : std_logic := '0';
begin
    u_word: selectWord
        port map (
            counter  => counter,
            sequence => random,
            word     => word);

    u_timer: timer
        generic map (
            CLOCK_FREQ => CLOCK_FREQ,
            SECONDS    => GAME_SECONDS)
        port map (
            clk     => clk,
            reset   => reset,
            clear   => pulseClear,
            expired => expired);

    u_button: singleButtonGame
        port map (
            clk     => clk,
            reset   => reset,
            clear   => pulseClear,
            timer   => expired,
            buttons => buttons,
            word    => word,
            done    => buttonOutput(0),
            error   => buttonOutput(1));

    process(reset, clk)
    begin
        if reset = '1' then
            done <= '0';
            error <= '0';
            pulseClear <= '0';
            counter <= (OTHERS => '0');
            reachedLimit <= '0';
        elsif rising_edge(clk) then
            if clear = '1' then
                pulseClear <= '1';
                done <= '0';
                error <= '0';
                counter <= (OTHERS => '0');
                reachedLimit <= '0';
            elsif reachedLimit = '1' then
                done <= '1';
                error <= '0';
            elsif buttonOutput = "10" then -- error
                done <= '0';
                error <= '1';
            elsif buttonOutput = "01" and pulseClear = '0' then -- done
                if counter = round then
                    reachedLimit <= '1';
                else
                    counter <= counter + 1;
                    pulseClear <= '1';
                end if;
            else
                pulseClear <= '0';
            end if;
        end if;
    end process;
end;