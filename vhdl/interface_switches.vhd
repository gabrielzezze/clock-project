LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY interface_switches IS
    PORT (
        sw_in    : IN std_logic_vector(9 DOWNTO 0);
        sw_out   : OUT std_logic_vector(7 DOWNTO 0);
        habilita : IN std_logic
    );
END ENTITY;

ARCHITECTURE comportamento OF interface_switches IS

BEGIN

    sw_out <= sw_in(7 downto 0) WHEN (habilita = '1') ELSE (OTHERS => 'Z');
    
END ARCHITECTURE;

