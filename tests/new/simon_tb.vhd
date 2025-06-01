library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity simon_tb is
end simon_tb;

architecture Behavioral of simon_tb is
    component simon
    generic(
        CLOCK_FREQ       : integer := 125_000_000;
        GAME_SECONDS     : integer range 0 to 15 := 2;
        PRINT_SECONDS    : integer range 0 to 15 := 1;
        WAIT_FRACTION    : integer range 0 to 15 := 4;
        SENTENCE_SECONDS : integer range 0 to 15 := 10;
        KEEP_CYCLES      : integer range 0 to 15 := 2;
        DEBOUNCE_CONTROL : integer range 0 to 15 := 10;
        SEED             : std_logic_vector(15 downto 0) := x"ABCD");
    port (
        clk, reset : IN std_logic;
        botones    : IN std_logic_vector(3 downto 0);
        leds       : OUT std_logic_vector(7 downto 0);
        segments   : OUT std_logic_vector(6 downto 0);
        selector   : OUT std_logic_vector(3 downto 0));
    end component;

    ----------------------------------------------------------------------------
    -- Señales internas para conectar con el DUT (Device Under Test)
    ----------------------------------------------------------------------------
    signal clk_tb      : std_logic := '0';
    signal reset_tb    : std_logic := '0';
    signal buttons_tb  : std_logic_vector(3 downto 0) := "0000";
    signal leds_tb     : std_logic_vector(7 downto 0) := "00000000";
    signal segments_tb : std_logic_vector(6 downto 0) := "0000000";
    signal selector_tb : std_logic_vector(3 downto 0) := "0000";

    ----------------------------------------------------------------------------
    -- Parámetro del período del reloj (20 ns => ~50 MHz)
    ----------------------------------------------------------------------------
    constant CLK_PERIOD : time := 20 ns;

begin

    ----------------------------------------------------------------------------
    -- Instanciación del módulo "simon"
    ----------------------------------------------------------------------------
    uut: simon
        generic map(
            CLOCK_FREQ    => 50,
            GAME_SECONDS  => 2,
            PRINT_SECONDS => 1,
            WAIT_FRACTION  => 4,
            SENTENCE_SECONDS => 10,
            KEEP_CYCLES => 2,
            DEBOUNCE_CONTROL => 2,
            SEED => x"ABCD")
        port map(
            clk      => clk_tb,
            reset    => reset_tb,
            botones  => buttons_tb,
            leds     => leds_tb,
            segments => segments_tb,
            selector => selector_tb);

    ----------------------------------------------------------------------------
    -- Generación del reloj
    ----------------------------------------------------------------------------
    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ----------------------------------------------------------------------------
    -- Proceso de estimulación (test)
    ----------------------------------------------------------------------------
    stim_process: process
    begin
        ------------------------------------------------------------------------
        -- 1) Reset inicial
        ------------------------------------------------------------------------
        reset_tb <= '1';
        wait for 50 ns;
        reset_tb <= '0';
        wait for 100 ns;

        ------------------------------------------------------------------------
        -- 2) Caso: status = "01" (imprimir secuencia), round=0
        --    El módulo calcula limit = round + 4 = 4. Se incrementa el 'counter'
        --    cuando "expired" genera flancos y status/= "00".
        ------------------------------------------------------------------------
        buttons_tb <= "0101";
        wait for 250 ns;
        buttons_tb <= "0000";
        wait for 1200 ns;
        buttons_tb <= "0100";
        wait for 500 ns;
        buttons_tb <= "0000";
        wait for 2500 ns;
        buttons_tb <= "0100";
        wait for 500 ns;
        buttons_tb <= "0000";
        wait for 50000 ns;

        wait;
    end process;


end Behavioral;
