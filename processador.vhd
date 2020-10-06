LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processador IS

    GENERIC (
        DATA_WIDTH : NATURAL := 16;
        ADDR_WIDTH : NATURAL := 22
    );
	 
    PORT (
        -- IN
        clk : IN std_logic;
		  
        -- OUT
        saidaAcumulador : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
        programCounter  : OUT std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0)
    );
	 
END ENTITY;

ARCHITECTURE main OF processador IS

    SIGNAL progCount       : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL saiAcumulador   : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL palavraControle : std_logic_vector(7 DOWNTO 0);
    SIGNAL opCode          : std_logic_vector(3 DOWNTO 0);
	 SIGNAL flag_zero			: std_logic;
	 
BEGIN
		  
    UC : ENTITY work.unidade_controle
			  GENERIC MAP(
					DATA_WIDTH => DATA_WIDTH,
					ADDR_WIDTH => ADDR_WIDTH
			  )
			  PORT MAP(
					palavraControle => palavraControle,
					opCode          => opCode,
					clk             => clk,
					flag_zero 		 => flag_zero
			  );
		  
END ARCHITECTURE;