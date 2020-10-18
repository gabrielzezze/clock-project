LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY interface_hex IS
    GENERIC (
        DATA_WIDTH : NATURAL := 8;
        ADDR_WIDTH : NATURAL := 9
    );
    PORT (
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 DOWNTO 0);
        endereco   : IN std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
        habilita : IN std_logic;
        valor    : IN std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
		  clk      : IN std_logic
    );
END ENTITY;

ARCHITECTURE comportamento OF interface_hex IS

    SIGNAL signal_hex0 : std_logic_vector(6 DOWNTO 0);
    SIGNAL signal_hex1 : std_logic_vector(6 DOWNTO 0);
    SIGNAL signal_hex2 : std_logic_vector(6 DOWNTO 0);
    SIGNAL signal_hex3 : std_logic_vector(6 DOWNTO 0);
    SIGNAL signal_hex4 : std_logic_vector(6 DOWNTO 0);
    SIGNAL signal_hex5 : std_logic_vector(6 DOWNTO 0);
	 
	 SIGNAL hab_HEX0 : std_logic;
    SIGNAL hab_HEX1 : std_logic;
    SIGNAL hab_HEX2 : std_logic;
    SIGNAL hab_HEX3 : std_logic;
    SIGNAL hab_HEX4 : std_logic;
    SIGNAL hab_HEX5 : std_logic;

BEGIN

    conversorHex0 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => valor(3 DOWNTO 0),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => signal_hex0);

    conversorHex1 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => valor(7 DOWNTO 4),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => signal_hex1);

    conversorHex2 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => valor(3 DOWNTO 0),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => signal_hex2);

    conversorHex3 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => valor(7 DOWNTO 4),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => signal_hex3);

    conversorHex4 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => valor(3 DOWNTO 0),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => signal_hex4);

    conversorHex5 : ENTITY work.conversorHex7Seg
        PORT MAP(
            dadoHex   => valor(7 DOWNTO 4),
            apaga     => '0',
            negativo  => '0',
            overFlow  => '0',
            saida7seg => signal_hex5);

    hab_HEX0 <= '1' WHEN endereco = "000000101" AND habilita = '1' ELSE '0';

    hab_HEX1 <= '1' WHEN endereco = "000000101" AND habilita = '1' ELSE '0';

    hab_HEX2 <= '1' WHEN endereco = "000000110" AND habilita = '1' ELSE '0';

    hab_HEX3 <= '1' WHEN endereco = "000000110" AND habilita = '1' ELSE '0';

    hab_HEX4 <= '1' WHEN endereco = "000000111" AND habilita = '1' ELSE '0';

    hab_HEX5 <= '1' WHEN endereco = "000000111" AND habilita = '1' ELSE '0';
		  
	 registrador_hex0 : ENTITY work.registrador_generico
	  GENERIC MAP(
			larguraDados => 7
	  )
	  PORT MAP(
			DIN    => signal_hex0,
			DOUT   => HEX0,
			ENABLE => hab_HEX0,
			CLK    => clk,
			RST    => '0'
	  );
	  
	  registrador_hex1 : ENTITY work.registrador_generico
	  GENERIC MAP(
			larguraDados => 7
	  )
	  PORT MAP(
			DIN    => signal_hex1,
			DOUT   => HEX1,
			ENABLE => hab_HEX1,
			CLK    => clk,
			RST    => '0'
	  );
	  
	  registrador_hex2 : ENTITY work.registrador_generico
	  GENERIC MAP(
			larguraDados => 7
	  )
	  PORT MAP(
			DIN    => signal_hex2,
			DOUT   => HEX2,
			ENABLE => hab_HEX2,
			CLK    => clk,
			RST    => '0'
	  );
	  
	  registrador_hex3 : ENTITY work.registrador_generico
	  GENERIC MAP(
			larguraDados => 7
	  )
	  PORT MAP(
			DIN    => signal_hex3,
			DOUT   => HEX3,
			ENABLE => hab_HEX3,
			CLK    => clk,
			RST    => '0'
	  );
	  
	  registrador_hex4 : ENTITY work.registrador_generico
	  GENERIC MAP(
			larguraDados => 7
	  )
	  PORT MAP(
			DIN    => signal_hex4,
			DOUT   => HEX4,
			ENABLE => hab_HEX4,
			CLK    => clk,
			RST    => '0'
	  );
	  
	  registrador_hex5 : ENTITY work.registrador_generico
	  GENERIC MAP(
			larguraDados => 7
	  )
	  PORT MAP(
			DIN    => signal_hex5,
			DOUT   => HEX5,
			ENABLE => hab_HEX5,
			CLK    => clk,
			RST    => '0'
	  );
    
END ARCHITECTURE;

