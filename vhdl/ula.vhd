LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- Biblioteca IEEE para funções aritméticas

ENTITY ULA IS
    GENERIC (
        larguraDados : NATURAL := 8
    );
    PORT (
        entradaA, entradaB : IN STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        seletor            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        saida              : OUT STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
        flagZero           : OUT std_logic
    );
END ENTITY;

ARCHITECTURE comportamento OF ULA IS
    CONSTANT zero : std_logic_vector(larguraDados - 1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL soma_b_a      : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL subtracao_b_a : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL soma_b_0      : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL soma_a_0      : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
    SIGNAL temp_saida    : STD_LOGIC_VECTOR((larguraDados - 1) DOWNTO 0);
BEGIN
    soma_b_a        <= STD_LOGIC_VECTOR(unsigned(entradaB) + unsigned(entradaA));
    subtracao_b_a   <= STD_LOGIC_VECTOR(unsigned(entradaB) - unsigned(entradaA));
    soma_b_0        <= entradaB;
    soma_a_0        <= entradaA;

    temp_saida <= soma_b_a WHEN (seletor = "000") ELSE
             subtracao_b_a WHEN (seletor = "001") ELSE
             soma_b_0 WHEN (seletor = "010") ELSE
             soma_a_0 WHEN (seletor = "011") ELSE
             entradaA; -- outra opcao: saida = entradaA

    flagZero <= '1' WHEN unsigned(temp_saida) = unsigned(zero) ELSE '0';
    saida <= temp_saida;
END ARCHITECTURE;