library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity lights_tb is
end lights_tb;

architecture Behavioral of lights_tb is
    component lights is
        generic (
            CLOCK_FREQ       : integer;
            PRINT_SECONDS    : integer range 0 to 15;
            WAIT_FRACTION    : integer range 0 to 15;
            SENTENCE_SECONDS : integer range 0 to 15 := 10);
        port(
            clk, reset, clear : IN  std_logic;
            status            : IN  std_logic_vector(1 downto 0);
            round             : IN  unsigned(2 downto 0);
            randomSequence    : IN  std_logic_vector(15 downto 0);
            selector          : OUT std_logic_vector(3 downto 0);
            finished          : OUT std_logic);
    end component;

    signal clk_tb, reset_tb, clear_tb : std_logic := '0';
    signal status_tb                  : std_logic_vector(1 downto 0)  := "00";
    signal round_tb                   : unsigned(2 downto 0)          := "000";
    signal randomSequence_tb          : std_logic_vector(15 downto 0) :=   b"00_10_01_11_00_00_10_11";
    signal selector_tb                : std_logic_vector(3 downto 0)  := "0000";
    signal finished_tb                : std_logic := '0';

    constant CLK_PERIOD : time := 20 ns;
begin
    uut: lights
        generic map(
            CLOCK_FREQ       => 50,
            PRINT_SECONDS    => 1,
            WAIT_FRACTION    => 4,
            SENTENCE_SECONDS => 10)
        port map(
            clk            => clk_tb,
            reset          => reset_tb,
            clear          => clear_tb,
            status         => status_tb,
            round          => round_tb,
            randomSequence => randomSequence_tb,
            selector       => selector_tb,
            finished       => finished_tb);

    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    stim_process: process
    begin
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for 60 ns;

        -- check printing sequence:
        wait for 20 ns;
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        status_tb <= "01";
        round_tb  <= "001";
        wait for 4000 ns;

        round_tb <= "010";
        wait for 310 ns;

        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 4000 ns;

        -- check win
        status_tb <= "10";
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 1000 ns;

        -- check loose
        status_tb <= "11";
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 20000 ns;

        -- check void
        status_tb <= "00";
        round_tb  <= to_unsigned(2, 3);
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 300 ns;

        wait;
    end process;


end Behavioral;
