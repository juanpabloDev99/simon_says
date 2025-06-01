library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity onePulseControl is
    port ( 
        clk, d , reset : IN  std_logic;
        q              : OUT  std_logic);
end onePulseControl;

architecture Behavioral of onePulseControl is
    signal setted : std_logic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then 
            q <= '0';
            setted <= '0';
        elsif rising_edge(clk) then
            if d = '1' and setted = '0' then
                q <= '1';
                setted <= '1';
            elsif d = '0' then
                setted <= '0';
                q <= '0';
            else
                q <= '0';
            end if;
        end if;
    end process;
end Behavioral;
