library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity keep_tb is
end keep_tb;

architecture Behavioral of keep_tb is
    component keepCycles is
        generic(KEEP_CYCLES: integer range 0 to 15 := 15);
        port(
            clk, d, reset, clear : in  std_logic;
            q      : out std_logic
        );
    end component;

    signal clk_tb, reset_tb   : std_logic := '0';
    signal d_tb   : std_logic := '0';
    signal q_tb   : std_logic := '0';
    signal clear_tb : std_logic := '0';

    constant CLK_PERIOD : time := 20 ns;
begin
    uut: keepCycles
        generic map (
            KEEP_CYCLES => 4
        )
        port map (
            clk => clk_tb,
            clear => clear_tb,
            d   => d_tb,
            q   => q_tb,
            reset => reset_tb
        );

    clk_process: process
    begin
        while true loop
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
        d_tb <= '1';
        wait for 200 ns; 
        
        d_tb <= '0';
        wait for 200 ns;

        d_tb <= '1';
        wait for 20 ns;
        d_tb <= '0';
        wait for 200 ns;
        
        d_tb <= '1';
        wait for 40 ns;
        clear_tb <= '1';
        wait for 40 ns;
        clear_tb <= '0';

        wait;
    end process;
end Behavioral;