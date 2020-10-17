LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY unidade_controle IS

    GENERIC (
        DATA_WIDTH : NATURAL := 8;
		ADDR_WIDTH : NATURAL := 9;
		TOTAL_WIDTH: NATURAL := 22
    );
	 
    PORT (
        -- IN
        clk    	: IN std_logic;
        opCode 	: IN std_logic_vector(3 DOWNTO 0);
		flag_zero_out	: IN std_logic;
		  
        -- OUT
        palavraControle : OUT std_logic_vector(9 DOWNTO 0)
    );
	 
END ENTITY;


ARCHITECTURE main OF unidade_controle IS

	ALIAS habFlag0             : std_logic IS palavraControle(9);
    ALIAS muxJump              : std_logic IS palavraControle(8);
    ALIAS muxImedRam           : std_logic IS palavraControle(7);
    ALIAS escritaReg           : std_logic IS palavraControle(6);
    ALIAS operacao             : std_logic_vector(2 DOWNTO 0) IS palavraControle(5 DOWNTO 3);
    ALIAS muxULAImedRam        : std_logic IS palavraControle(2);
    ALIAS habEscritaRAM        : std_logic IS palavraControle(1);
	ALIAS habLeituraRAM        : std_logic IS palavraControle(0);
	 
	-- Add
	CONSTANT op_code_add  		: std_logic_vector(3 DOWNTO 0) := "0001";
	 
	-- Sub
	CONSTANT op_code_sub  		: std_logic_vector(3 DOWNTO 0) := "0010";
	 
	-- Lea
	CONSTANT op_code_lea  		: std_logic_vector(3 DOWNTO 0) := "0011";
		
	-- Tipos MOVs
    CONSTANT op_code_mov_mr  	: std_logic_vector(3 DOWNTO 0) := "0100";
	CONSTANT op_code_mov_rm  	: std_logic_vector(3 DOWNTO 0) := "0101";
	CONSTANT op_code_mov_rr  	: std_logic_vector(3 DOWNTO 0) := "0110";
	 
	-- Cmp
	CONSTANT op_code_cmp  		: std_logic_vector(3 DOWNTO 0) := "0111";
	 
	-- Je
	CONSTANT op_code_jmp  		: std_logic_vector(3 DOWNTO 0) := "1000";
	 
    -- Jmp
	CONSTANT op_code_je  		: std_logic_vector(3 DOWNTO 0) := "1001";
	
	SIGNAL instrucao         : std_logic_vector(8 DOWNTO 0);
	
	-- Alias
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

	muxJump  <=  jmp OR (je AND flag_zero_out);
    muxImedRam    <= mov_mr;
    escritaReg    <= add OR sub OR lea OR mov_mr or mov_rr;
    muxULAImedRam <= lea OR mov_mr;
    habEscritaRAM <= mov_rm;
	habLeituraRAM <= mov_mr;
	habFlag0 <= '1' WHEN op_code_cmp = opCode ELSE '0';

	 
    WITH opCode SELECT
        operacao <= "000" WHEN op_code_add,
		"001" WHEN op_code_cmp,
		"001" WHEN op_code_sub,
        "010" WHEN op_code_mov_rr,
        "000" WHEN OTHERS;
	 
END ARCHITECTURE;