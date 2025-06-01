library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keepCycles is
    generic(KEEP_CYCLES : integer range 0 to 15 := 15);
    port ( 
        clk, reset, clear, d : IN  std_logic;
        q                    : OUT  std_logic);
end keepCycles;

architecture Behavioral of keepCycles is
    type STATE_TYPE is (IDLE, SET_ON, SET_OFF);

    -- IDLE q <= 0, cuando se detecta d = 1 > SET_ON
    -- SET_ON q <= 1, hasta que counter termine > SET_OFF
    -- SET_OFF q <= 0, cuando d = 0 > IDLE

    signal counter : unsigned(KEEP_CYCLES downto 0) := (OTHERS => '0');
    signal finished : boolean := false;
    signal current_state : STATE_TYPE;
begin
    finished <= (counter = to_unsigned(KEEP_CYCLES, counter'length));

    process(reset, clk)
    begin
        if reset = '1' then
            current_state <= IDLE;
            counter <= (OTHERS => '0');
            q <= '0';
        elsif rising_edge(clk) then
            if clear = '1' then
                current_state <= IDLE;
                counter <= (OTHERS => '0');
                q <= '0';
            elsif current_state = IDLE and d = '1' then
                current_state <= SET_ON;
                q <= '1';
            elsif current_state = SET_ON then
                if finished then
                    current_state <= SET_OFF;
                    q <= '0';
                else
                    counter <= counter + 1;
                end if;
            elsif current_state = SET_OFF and d = '0' then
                current_state <= IDLE;
                counter <= (OTHERS => '0');
                q <= '0';
            end if;
        end if;
    end process;
end Behavioral;
