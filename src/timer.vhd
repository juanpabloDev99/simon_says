library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
	generic (
		CLOCK_FREQ : integer := 125_000_000;
		SECONDS: integer range 0 to 15 := 2);
	port (
		clk, reset, clear : IN std_logic;
		expired           : OUT std_logic
	);
end entity timer;

architecture Behavioral of timer is
	signal counter : unsigned(32 downto 0) := (OTHERS => '0');
	signal target : unsigned(32 downto 0) := (OTHERS => '0');
	signal isEqual : boolean := false;
begin
	target <= to_unsigned(CLOCK_FREQ * SECONDS, 33);
    isEqual <= target = counter;

	process(reset, clk) begin
        if reset = '1' then
			counter <= (OTHERS => '0');
			expired <= '0';
		elsif rising_edge(clk) then
			if clear = '1' then
		    	counter <= (OTHERS => '0');
		    	expired <= '0';
			elsif isEqual then
            	expired <= '1';
    		else
            	counter <= counter + 1;
    		end if;
		end if;
	end process;
end;