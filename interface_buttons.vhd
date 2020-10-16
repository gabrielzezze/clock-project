LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY interface_buttons IS
    GENERIC (
        ADDR_WIDTH     : NATURAL := 9
    );
    PORT (
        btn_in      : IN std_logic_vector(3 DOWNTO 0);
        endereco    : IN std_logic_vector(ADDR_WIDTH - 1 downto 0);
        habilita    : IN std_logic;
        btn_out     : OUT std_logic_vector(7 downto 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF interface_buttons IS

    SIGNAL sinal: std_logic_vector(7 DOWNTO 0);

BEGIN

WITH endereco SELECT    sinal <=    "0000000" & btn_in(0)   WHEN   "000000001",
                                    "0000000" & btn_in(1)   WHEN   "000000010",
                                    "0000000" & btn_in(2)   WHEN   "000000011",
                                    "0000000" & btn_in(3)   WHEN   "000000100",
                                    "00000000"              WHEN   OTHERS;

    btn_out <= sinal WHEN (habilita = '1') ELSE (OTHERS => 'Z');
    
END ARCHITECTURE;
