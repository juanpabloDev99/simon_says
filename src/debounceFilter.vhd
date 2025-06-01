library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounceFilter is
    generic(DEBOUNCE_CONTROL : integer range 0 to 15 := 10);
    port ( 
        reset: IN std_logic ;
        clk : IN  std_logic;
        pul : IN  std_logic;
        q : OUT  std_logic);
end debounceFilter;

architecture Behavioral of debounceFilter is
    signal biestable : std_logic_vector(1 downto 0) := "01";
    signal rebote : std_logic := '0';
    signal cuenta : unsigned(DEBOUNCE_CONTROL downto 0) := (OTHERS => '0');
begin
    process(clk, reset)
    begin
        if reset= '1' then 
            biestable <= "01";
            rebote <= '0';
            q <= '0';
            cuenta <= (others => '0');
        elsif rising_edge(clk) then
            biestable <= biestable(0) & pul;
            rebote <= biestable(0) XOR biestable(1);
			if (rebote = '1') then
                cuenta <= (others => '0');
                q <= '0';
			elsif (cuenta(DEBOUNCE_CONTROL) = '0') and biestable(1) = '1' then
                cuenta <= cuenta + 1;
			else
                q <= biestable(1);
			end if;
        end if;
    end process;
end Behavioral;
