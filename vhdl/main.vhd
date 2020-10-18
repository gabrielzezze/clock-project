LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY main IS

    GENERIC (
        -- Tamanho do valor imediato determinado na 
        -- etapa de design do processador.
        DATA_WIDTH : NATURAL := 8;

        -- Tamanho dos endereços ROM/RAM determinado na 
        -- etapa de design do processador.
        ADDR_WIDTH : NATURAL := 9;

        -- Tamanho das instrucoes completas determinado na 
        -- etapa de design do processador.
        TOTAL_WIDTH: NATURAL := 22
    );

    PORT (
        -- SINAIS DE ENTRADA --
        -- Clock vindo da placa FPGA
        -- aproximadamente 50 MHz.
        CLOCK_50     : IN std_logic;

        -- Sinal das chaves da placa FPGA
        SW           : IN std_logic_vector(9 DOWNTO 0);
        -- Sinal dos Botões da placa FPGA
        KEY          : IN std_logic_vector(3 DOWNTO 0);
        -- Sinal do botão Reset da placa FPGA
        FPGA_RESET_N : IN std_logic;


        -- SINAIS DE SAÍDA --
        -- Sinal dos leds da placa.
        LEDR                               : OUT std_logic_vector(9 DOWNTO 0);

        -- Displays hexadecimais usados para mostrar 
        -- os segundos, minutos e horas.
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 DOWNTO 0)
    );
	 
END ENTITY;


ARCHITECTURE main OF main IS

BEGIN
    -- Instância do componente processador
    processador : ENTITY work.processador
        GENERIC MAP(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        PORT MAP(
            clk => CLOCK_50,
            SW => SW,
            KEY => KEY,
            HEX0 => HEX0,
            HEX1 => HEX1,
            HEX2 => HEX2,
            HEX3 => HEX3,
            HEX4 => HEX4,
            HEX5 => HEX5
        ); 
		 
END ARCHITECTURE;