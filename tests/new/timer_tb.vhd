library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity timer_tb is
end timer_tb;

architecture Behavioral of timer_tb is
    component timer is
        generic (
            CLOCK_FREQ : integer := 125_000_000;
            SECONDS    : integer range 0 to 15 := 2
        );
        port (
            clk, reset, clear : IN  std_logic;
            expired           : OUT std_logic
        );
    end component;

    signal clk_tb, reset_tb, clear_tb : std_logic := '0';
    signal expired_tb                 : std_logic := '0';

    constant CLK_PERIOD : time := 5 ns;
begin
    uut: timer
        generic map(
            CLOCK_FREQ => 50,
            SECONDS    => 1
        )
        port map(
            clk     => clk_tb,
            reset   => reset_tb,
            clear   => clear_tb,
            expired => expired_tb
        );

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
        wait for 400 ns;
        
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';       
        wait;
    end process;
end Behavioral;
