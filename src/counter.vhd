library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity counter is
	generic(N: integer := 8);
	port(
		step, reset: IN std_logic;
		q: OUT std_logic_vector(N-1 downto 0)
	);
end;

architecture synth of counter is
    signal count: unsigned(N-1 downto 0) := (OTHERS => '0');
begin
	process(step, reset) begin
		IF (reset = '1') then count <= (OTHERS => '0');
		ELSIF rising_edge(step) then count <= count + 1;
		end IF;
	end process;

	q <= std_logic_vector(count);
end;