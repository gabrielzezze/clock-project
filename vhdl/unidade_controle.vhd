LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY unidade_controle IS

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
		clk    	: IN std_logic;
		
		-- Primeiros 4 bits da instrução vindo do fluxo de dados
		-- recebido aqui para auxiliar na criação da palavra controle.
		opCode 	: IN std_logic_vector(3 DOWNTO 0);
		
		-- Sinal vindo do fluxo de dados e utilizado aqui para determinar se o ponto de controle 
		-- "muxJump" deve ser acionado no caso de uma instruçāo JE.
		flag_zero_out	: IN std_logic;
			
		
		-- SINAIS DE SAÍDA --
		-- Pontos de controle concatenados, determinado aqui a partir do opcode e valor da flag zero.
		palavraControle : OUT std_logic_vector(9 DOWNTO 0)
    );
	 
END ENTITY;


ARCHITECTURE main OF unidade_controle IS

	-- ALIASES --
	-- Usados para facilitar a montagem da palavra controle. --
	ALIAS habFlag0             : std_logic IS palavraControle(9);
    ALIAS muxJump              : std_logic IS palavraControle(8);
    ALIAS muxImedRam           : std_logic IS palavraControle(7);
    ALIAS escritaReg           : std_logic IS palavraControle(6);
    ALIAS operacao             : std_logic_vector(2 DOWNTO 0) IS palavraControle(5 DOWNTO 3);
    ALIAS muxULAImedRam        : std_logic IS palavraControle(2);
    ALIAS habEscritaRAM        : std_logic IS palavraControle(1);
	ALIAS habLeituraRAM        : std_logic IS palavraControle(0);
	

	-- CONSTANTS --
	-- Utilizados para melhor semântica em blocos de lógica.

	-- Opcode no caso de uma operação ADD
	CONSTANT op_code_add  		: std_logic_vector(3 DOWNTO 0) := "0001";
	 
	-- Opcode no caso de uma operação SUB
	CONSTANT op_code_sub  		: std_logic_vector(3 DOWNTO 0) := "0010";
	 
	-- Opcode no caso de uma operação LEA
	CONSTANT op_code_lea  		: std_logic_vector(3 DOWNTO 0) := "0011";
		
	-- Tipos MOVs
	-- Opcode no caso de uma operação MOVMR
	CONSTANT op_code_mov_mr  	: std_logic_vector(3 DOWNTO 0) := "0100";
	-- Opcode no caso de uma operação MOVRM
	CONSTANT op_code_mov_rm  	: std_logic_vector(3 DOWNTO 0) := "0101";
	-- Opcode no caso de uma operação MOVRR
	CONSTANT op_code_mov_rr  	: std_logic_vector(3 DOWNTO 0) := "0110";
	 
	-- Opcode no caso de uma operação CMP
	CONSTANT op_code_cmp  		: std_logic_vector(3 DOWNTO 0) := "0111";
	 
	-- Opcode no caso de uma operação JE
	CONSTANT op_code_jmp  		: std_logic_vector(3 DOWNTO 0) := "1000";
	 
    -- Opcode no caso de uma operação JMP
	CONSTANT op_code_je  		: std_logic_vector(3 DOWNTO 0) := "1001";
	

	-- SINAIS --
	-- Pontos de controle concatenados (palavra controle).
	SIGNAL instrucao         : std_logic_vector(8 DOWNTO 0);
	
	-- ALIAS --
	-- Usados para facilitar a semantica dos blocos de lógica.
    ALIAS add      	    : std_logic IS instrucao(0);
    ALIAS sub      	    : std_logic IS instrucao(1);
	ALIAS lea      	    : std_logic IS instrucao(2);
    ALIAS mov_mr        : std_logic IS instrucao(3);
    ALIAS mov_rm 		: std_logic IS instrucao(4);
    ALIAS mov_rr 		: std_logic IS instrucao(5);
	ALIAS cmp 			: std_logic IS instrucao(6);
	ALIAS jmp 			: std_logic IS instrucao(7);
	ALIAS je 			: std_logic IS instrucao(8);
	 
BEGIN

    WITH opCode SELECT instrucao <= "000000001" WHEN op_code_add,
												"000000010" WHEN op_code_sub,
												"000000100" WHEN op_code_lea,
												"000001000" WHEN op_code_mov_mr,
												"000010000" WHEN op_code_mov_rm,
												"000100000" WHEN op_code_mov_rr,
												"001000000" WHEN op_code_cmp,
												"010000000" WHEN op_code_jmp,
												"100000000" WHEN op_code_je,
												"000000000" WHEN OTHERS;


	-- Seletor do mux o qual determina se a proxima instrução da ROM usada é a proxima da ordem
	-- ou uma instrução a qual seu endereço na ROM está nos ultimos 9 bits da instrução 
	-- (caso a operação seja um JMP ou JE). 
	muxJump  <=  jmp OR (je AND flag_zero_out);

	-- Seletor do mux o qual determina se o valor imediato ou valor do barramento de dados
	-- será utilizado na entrada 1 do "muxULAImedRam".
	muxImedRam    <= mov_mr;
	
	-- Sinal que determina se a saída do "muxULAImedRam" será salvo no
	-- registrador C o qual endereço esta nos bits 11 - 9 da instrução.
	escritaReg    <= add OR sub OR lea OR mov_mr or mov_rr;
	
	-- Seletor do mux o qual determina se a saída da ULA ou a saída do "muImedRam"
	-- será salvo no registrador C o qual endereço esta nos bits 11 - 9 da instrução.
	muxULAImedRam <= lea OR mov_mr;
	
	-- Sinal que possibilita a leitura de valores da memória RAM
	-- caso seja habilitado.
	habEscritaRAM <= mov_rm;
	
	-- Sinal que possibilita a escrita de valores na memória RAM
	-- caso seja habilitado.
	habLeituraRAM <= mov_mr;

	-- Habilita a escrita do flag zero no flip flop especificado para este.
	habFlag0 <= '1' WHEN op_code_cmp = opCode ELSE '0';

	-- Logica a qual determina a operação da ULA presente na palavra controle
	-- dependendo do opcode recebido.
    WITH opCode SELECT
        operacao <= "000" WHEN op_code_add,
		"001" WHEN op_code_cmp,
		"001" WHEN op_code_sub,
        "010" WHEN op_code_mov_rr,
        "000" WHEN OTHERS;
	 
END ARCHITECTURE;