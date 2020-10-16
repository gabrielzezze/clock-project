LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY decodificador_enderecos IS
    GENERIC (
        ADDR_WIDTH : NATURAL := 8
    );
    PORT (
        seletor  : IN std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
        habilita : OUT std_logic_vector(5 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF decodificador_enderecos IS

    SIGNAL num_endereco : unsigned(ADDR_WIDTH - 1 DOWNTO 0);

BEGIN
    num_endereco(ADDR_WIDTH - 1 DOWNTO 0) <= unsigned(seletor);

    -- RAM
    habilita(0) <= '1' WHEN num_endereco >= 64 AND num_endereco < 128 ELSE '0';

    -- Hex
    habilita(1) <= '1' WHEN num_endereco >= 5 AND num_endereco <= 7 ELSE '0';

    -- Ler Temp 
    habilita(2) <= '1' WHEN num_endereco = 8 ELSE'0';

    -- Botao
    habilita(3) <= '1' WHEN num_endereco >= 1 AND num_endereco < 5 ELSE '0';

    -- Switch
    habilita(4) <= '1' WHEN num_endereco = 0 ELSE '0';

    -- Clear Temp
    habilita(5) <= '1' WHEN num_endereco = 9 ELSE '0';
    
END ARCHITECTURE;

