library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity singleButtonGame is
	port(
		clk, reset, clear, timer : IN std_logic;
		buttons, word            : IN std_logic_vector(3 downto 0);
		done, error              : OUT std_logic);
end;

architecture Behavioural of singleButtonGame is
    signal active, isEqual, isDifferent, isSetted, isClicked : std_logic := '0';
    signal controlledTimer                        : std_logic := '0';
    signal controlledButtons                      : std_logic_vector(3 downto 0) := "0000";

begin
    isEqual <= '0' when word = "0000" else
               '1' when buttons = word else
               '0';
    isDifferent <= '0' when buttons = "0000" else
                   '1' when isEqual = '0' else
                   '0';

    process(reset, clk)
    begin
        if reset = '1' then
            done <= '0';
            error <= '0';
            active <= '1';
        elsif rising_edge(clk) then
            if clear = '1' then
                done <= '0';
                error <= '0';
                active <= '1';
            elsif active = '1' then
                if timer = '1' then
                    done <= '0';
                    error <= '1';
                    active <= '0';
                elsif isEqual = '1' then
                    done <= '1';
                    error <= '0';
                    active <= '0';
                elsif isDifferent = '1' then
                    done <= '0';
                    error <= '1';
                    active <= '0';
                end if;
            end if;
        end if;
    end process;
end;