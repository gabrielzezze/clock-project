LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY clock IS

    PORT (
        -- IN
        CLOCK_50     : IN std_logic;
        SW           : IN std_logic_vector(9 DOWNTO 0);
        KEY          : IN std_logic_vector(3 DOWNTO 0);
        FPGA_RESET_N : IN std_logic;

        -- OUT
        LEDR                               : OUT std_logic_vector(9 DOWNTO 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 DOWNTO 0)
    );
	 
END ENTITY;


ARCHITECTURE main OF clock IS

	BEGIN
		 LEDR(5 DOWNTO 0) <= SW(5 DOWNTO 0);
		 LEDR(9 DOWNTO 6) <= NOT KEY(3 DOWNTO 0);
		 
END ARCHITECTURE;