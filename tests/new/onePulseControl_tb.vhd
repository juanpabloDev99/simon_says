----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.01.2025 16:51:28
-- Design Name: 
-- Module Name: oneClick - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity onePulseControl_tb is
--  Port ( );
end onePulseControl_tb;

architecture Behavioral of onePulseControl_tb is
component onePulseControl is
        port(
            clk,reset : in std_logic;
            d   : in std_logic;
            q   : out std_logic
            
        );
    end component;

    
    signal clk_tb,reset_tb : std_logic := '0';
    signal d_tb   : std_logic := '0';
    signal q_tb   : std_logic;

    
    constant CLK_PERIOD : time := 10 ns;

begin

  
    uut: onePulseControl
        port map(
            clk => clk_tb,
            d   => d_tb,
            q   => q_tb,
            reset=> reset_tb
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
      
        wait for 40 ns;

       
        d_tb <= '1';
        wait for 30 ns;
       
       reset_tb<= '1';
        wait for 10 ns;
        reset_tb<= '0';
       
        wait for 40 ns;

       
        d_tb <= '0';
        wait for 40 ns;
 
        d_tb <= '1';
        wait for 10 ns;
        d_tb <= '0';
        wait for 40 ns;

     
        d_tb <= '1';
        wait for 10 ns;
        d_tb <= '0';
        wait for 10 ns;
        d_tb <= '1';
        wait for 10 ns;
        d_tb <= '0';
        wait for 20 ns;
        
        d_tb <= '1';
        wait for 1000 ns;

        
        wait;
    end process;


end Behavioral;
