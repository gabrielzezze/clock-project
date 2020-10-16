LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity divisor_generico_interface is

    GENERIC (
        DATA_WIDTH : NATURAL := 8
    );

   port(
        clk                 :   in std_logic;
        habilitaLeitura     : in std_logic;
        limpaLeitura        : in std_logic;
        leituraUmSegundo    :   out std_logic_vector((DATA_WIDTH - 1) DOWNTO 0)
   );

end entity;

architecture interface of divisor_generico_interface is

  signal sinalUmSegundo : std_logic;
  signal saidaclk_reg1seg : std_logic;

begin

baseTempo: entity work.divisor_generico
           generic map (divisor => 5)   -- divide por 10.
           port map (clk => clk, saida_clk => saidaclk_reg1seg);

registraUmSegundo: entity work.flip_flop_generico
   port map (
        DIN => '1',
        DOUT => sinalUmSegundo,
        ENABLE => '1',
        CLK => saidaclk_reg1seg,
        RST => limpaLeitura
    );

-- Faz o tristate de saida:
leituraUmSegundo <= ("0000000" & sinalUmSegundo) when habilitaLeitura = '1' else (OTHERS => 'Z');

end architecture interface;
