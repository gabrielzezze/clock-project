LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- O processador é responsável por integrar a unidade de controle ao fluxo de dados
ENTITY processador IS

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
        clk : IN std_logic;

        -- Switches da placa
        SW  : IN std_logic_vector(9 DOWNTO 0);

        -- Botoes da placa
        KEY          : IN std_logic_vector(3 DOWNTO 0);
          
    
        -- SINAIS DE SAÍDA --
        -- Valores escritos nos displays hexadecimais
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 DOWNTO 0)
    );
	 
END ENTITY;

ARCHITECTURE main OF processador IS
    

    -- Pontos de controles concatenados vindos da unidade de controle
    -- os quais são usados no fluxo de dados para as habilitações e seleções apropriadas
    -- com a instrução do momento.
    SIGNAL palavraControle : std_logic_vector(9 DOWNTO 0);

    -- Codigo da operação vindo da instrução salva na ROM retornado pelo fluxo de dados
    -- usado na unidade de controle para auxiliar na criação da palavra de controle.
    -- Primeiros 4 bits da instrução.
    SIGNAL opCode          : std_logic_vector(3 DOWNTO 0);

    -- Sinal que recebe o valor da flag zero, retornada pela ULA através do fluxo de dados,
    -- no caso de uma operação CMP a qual será usada na unidade de controle para determinar 
    -- se uma operação JE deve ser comprida.
	SIGNAL flag_zero_out	   : std_logic;
	 
BEGIN

	-- Instância da unidade de controle.
    UC : ENTITY work.unidade_controle
            GENERIC MAP(
                DATA_WIDTH => DATA_WIDTH,
                ADDR_WIDTH => ADDR_WIDTH
            )
            PORT MAP(
                palavraControle => palavraControle,
                opCode          => opCode,
                clk             => clk,
                flag_zero_out 	=> flag_zero_out
            );

    -- Instância do componente resposável pelo fluxo de dados .   
    FD: ENTITY work.fluxo_dados
            GENERIC MAP(
                DATA_WIDTH => DATA_WIDTH,
                ROM_DATA_WIDTH => ADDR_WIDTH,
                ADDR_WIDTH => ADDR_WIDTH,
                TOTAL_WIDTH => TOTAL_WIDTH
            )
            PORT MAP(
                clk => clk,
                palavraControle => palavraControle,
                flag_zero_out   => flag_zero_out,
                opCode => opCode,
                sw => SW,
                KEY => KEY,
                HEX0 => HEX0,
                HEX1 => HEX1,
                HEX2 => HEX2,
                HEX3 => HEX3,
                HEX4 => HEX4,
                HEX5 => HEX5
            );
		  
END ARCHITECTURE;