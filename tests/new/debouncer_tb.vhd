library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce_tb is
end debounce_tb;

architecture Behavioral of debounce_tb is

   
    component debounceFilter is
        generic(DEBOUNCE_CONTROL : integer range 0 to 15 := 4);
        port(
            clk,reset : in  std_logic;
            pul : in  std_logic;
            q   : out std_logic
        );
    end component;

    signal clk_tb : std_logic := '0';
    signal pul_tb ,reset_tb: std_logic := '0';
    signal q_tb   : std_logic;

    constant CLK_PERIOD : time := 20 ns;
begin
    uut: debounceFilter
        generic map(DEBOUNCE_CONTROL => 4)
        port map(
            clk => clk_tb,
            pul => pul_tb,
            q   => q_tb,
            reset =>reset_tb);

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
        
        wait for 100 ns;

      
        pul_tb <= '1';
        wait for 20 ns;   
        pul_tb <= '0';
        wait for 50 ns;
        pul_tb <= '1';
        wait for 10 ns;
        pul_tb <= '0';
        wait for 20 ns;
        pul_tb <= '1';
         wait for 2000 ns;
        
        
        reset_tb<= '1';
         wait for 100 ns;         
        reset_tb<= '0';
        
          wait for 7000 ns;   
  
        pul_tb <= '0';
        wait for 100 ns;
        pul_tb <= '1';
        wait for 10 ns;
        pul_tb <= '0';
        wait for 10 ns;
        pul_tb <= '1';
        wait for 10 ns;
        pul_tb <= '0';

   wait for 200 ns;
        reset_tb<= '1';
         wait for 100 ns;
         
        reset_tb<= '0';
       

       
         wait for 100 ns;   
    end process;


end Behavioral;
