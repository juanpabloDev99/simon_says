--------------------------------------------------------------------------------
-- Test Bench en VHDL para el módulo "game" con explicaciones en español
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_tb is
end game_tb;

architecture Behavioral of game_tb is
    ----------------------------------------------------------------------------
    -- Componente correspondiente al módulo "game"
    ----------------------------------------------------------------------------
    component game is
        generic (
            CLOCK_FREQ   : integer := 125_000_000;
            GAME_SECONDS : integer range 0 to 15 := 2);
        port(
            clk, reset, clear  : IN std_logic;
            buttons            : IN std_logic_vector(3 downto 0);
            round              : IN unsigned(2 downto 0);
            random             : IN std_logic_vector(15 downto 0);
            done, error        : OUT std_logic);
    end component;

    ----------------------------------------------------------------------------
    -- Señales internas que conectaremos al DUT (Device Under Test)
    ----------------------------------------------------------------------------
    signal clk_tb, reset_tb, clear_tb : std_logic := '0';
    signal button_tb   : std_logic_vector(3 downto 0) := (others => '0');
    signal round_tb    : unsigned(2 downto 0)         := "000";
    signal random_tb   : std_logic_vector(15 downto 0) := b"00_10_01_11_00_00_10_11";
    signal done_tb     : std_logic;
    signal error_tb    : std_logic;

    -- Período del reloj (20 ns = 50 MHz aprox.)
    constant CLK_PERIOD : time := 20 ns;

begin

    ----------------------------------------------------------------------------
    -- Instanciación del módulo "game"
    ----------------------------------------------------------------------------
    uut: game
        generic map(
            CLOCK_FREQ   => 50,
            GAME_SECONDS => 1
        )
        port map(
            clk     => clk_tb,
            reset   => reset_tb,
            clear   => clear_tb,
            buttons => button_tb,
            round   => round_tb,
            random  => random_tb,
            done    => done_tb,
            error   => error_tb
        );

    ----------------------------------------------------------------------------
    -- Generación del reloj (clk_tb)
    ----------------------------------------------------------------------------
    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    ----------------------------------------------------------------------------
    -- Proceso de estimulación (stim_process)
    ----------------------------------------------------------------------------
    stim_process: process
    begin
        ------------------------------------------------------------------------
        -- Ejemplo 1: Reset global y prueba con "round=0" (4 rondas)
        ------------------------------------------------------------------------
        reset_tb <= '1';
        wait for 50 ns;
        reset_tb <= '0';

        round_tb <= to_unsigned(1, 3);  -- "round=1", implica "limit = 5"
        wait for 100 ns;

        ------------------------------------------------------------------------
        -- Simulamos cuatro aciertos consecutivos
        ------------------------------------------------------------------------
        button_tb <= "0001";  -- 6
        wait for 20 ns;
        button_tb <= "0000";
        wait for 150 ns;
        
        button_tb <= "0010";  -- 5
        wait for 20 ns;
        button_tb <= "0000";
        wait for 150 ns;
        
        button_tb <= "0100";  -- D (13)
        wait for 20 ns;
        button_tb <= "0000";
        wait for 150 ns;
        
        button_tb <= "0100";  -- 3
        wait for 20 ns;
        button_tb <= "0000";
        wait for 150 ns;
        
        button_tb <= "0001";  -- 3
        wait for 20 ns;
        button_tb <= "0000";
        wait for 200 ns;

        ------------------------------------------------------------------------
        -- Si se han hecho los 4 aciertos, la señal done_tb debería ponerse '1'.
        ------------------------------------------------------------------------
        wait for 200 ns;

        ------------------------------------------------------------------------
        -- Ejemplo 2: Reset y probamos un error
        ------------------------------------------------------------------------
        reset_tb <= '1';
        wait for 50 ns;
        reset_tb <= '0';
        round_tb <= to_unsigned(1, 3);  -- "round=1", implica "limit = 5"
        wait for 100 ns;

        button_tb <= "1010";  -- Presionamos un valor que no coincide con la palabra
        wait for 100 ns;
        button_tb <= "0000";
        wait for 200 ns;

        ------------------------------------------------------------------------
        -- Aquí debería verse la señal error_tb = '1'.
        ------------------------------------------------------------------------
        wait for 300 ns;
        reset_tb <= '1';
        wait for 50 ns;
        reset_tb <= '0';
        wait for 1200 ns;

        ------------------------------------------------------------------------
        -- Fin de la simulación
        ------------------------------------------------------------------------
        wait;
    end process;
end Behavioral;
