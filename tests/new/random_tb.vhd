library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity random_tb is
end random_tb;

architecture Behavioral of random_tb is
component random
        port (
            clk, reset, clear, enable : IN std_logic;
            sequence                  : OUT std_logic_vector(15 downto 0));
    end component;

    signal clk_tb, reset_tb, clear_tb, enable_tb : STD_LOGIC := '0';
    signal seq_tb                                : STD_LOGIC_VECTOR(15 downto 0);

    constant CLK_PERIOD : time := 20 ns;
begin
    uut: random
        port map (
            clk      => clk_tb,
            reset    => reset_tb,
            clear    => clear_tb,
            enable   => enable_tb,
            sequence => seq_tb);

    clk_process: process
    begin
        while True loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    stim_process: process
    begin
        reset_tb <= '1';
        wait for 20 ns;     
        reset_tb <= '0';
        wait for 100 ns;

        enable_tb <= '1';
        wait for 200 ns;

        enable_tb <= '0';
        wait for 200 ns;

        clear_tb <= '1';
        enable_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 260 ns;
        enable_tb <= '0';
        wait for 200 ns;

        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait;
    end process;
end Behavioral;