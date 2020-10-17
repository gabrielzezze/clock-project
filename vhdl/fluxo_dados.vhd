LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fluxo_dados IS

    GENERIC (
        DATA_WIDTH     : NATURAL := 8;
        ROM_DATA_WIDTH : NATURAL := 9;
        ADDR_WIDTH     : NATURAL := 9;
        TOTAL_WIDTH: NATURAL := 22;
        REG_WIDTH: NATURAL := 3
    );
    PORT (
        -- IN
        clk             : IN std_logic;
        palavraControle : IN std_logic_vector(8 DOWNTO 0);
        SW              : IN std_logic_vector(9 DOWNTO 0);
        KEY             : IN std_logic_vector(3 DOWNTO 0);

        -- OUT
        opCode          : OUT std_logic_vector(3 DOWNTO 0);
        saidaAcumulador : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
        programCounter  : OUT std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
        flag_zero       : OUT std_logic;
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 DOWNTO 0)
    );

END ENTITY;

ARCHITECTURE main OF fluxo_dados IS

    SIGNAL Instrucao                  : std_logic_vector(TOTAL_WIDTH - 1 DOWNTO 0);
    SIGNAL PC_ROM                     : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL SomaUm_MuxProxPC           : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL MuxProxPC_PC               : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaULA                   : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL habilitaPerifericos        : std_logic_vector(5 DOWNTO 0);

    -- Saidas Intermediarias
    SIGNAL saidaMuxImedRam            : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaMuxULAImed_ou_RAM     : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaRegA, saidaRegB       : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    
    -- Barramentos
    SIGNAL barramentoEntradaDados     : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);


    ALIAS opCodeLocal                 : std_logic_vector(3 DOWNTO 0) IS Instrucao(21 DOWNTO 18);
    ALIAS enderecoRAM                 : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(ADDR_WIDTH - 1 DOWNTO 0);
    ALIAS enderecoJUMP                : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(ADDR_WIDTH - 1 DOWNTO 0);
    ALIAS imediato_entradaExtSinal    : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(ADDR_WIDTH - 1 DOWNTO 0);

    ALIAS muxJump                     : std_logic IS palavraControle(8);
    ALIAS muxImedRam                  : std_logic IS palavraControle(7);
    ALIAS escritaReg                  : std_logic IS palavraControle(6);
    ALIAS operacao                    : std_logic_vector(2 DOWNTO 0) IS palavraControle(5 DOWNTO 3);
    ALIAS muxULAImedRam               : std_logic IS palavraControle(2);
    ALIAS habEscritaRAM               : std_logic IS palavraControle(1);
    ALIAS habLeituraRAM               : std_logic IS palavraControle(0);

    ALIAS habilitaCLRTemp             : std_logic IS habilitaPerifericos(5);
    ALIAS habilitaSW                  : std_logic IS habilitaPerifericos(4);
    ALIAS habilitaBTN                 : std_logic IS habilitaPerifericos(3);
    ALIAS habilitaTemp                : std_logic IS habilitaPerifericos(2);
    ALIAS habilitaHex                 : std_logic IS habilitaPerifericos(1);
    ALIAS habilitaRAM                 : std_logic IS habilitaPerifericos(0);
    
    
    CONSTANT INCREMENTO : NATURAL := 1;
BEGIN

    PC : ENTITY work.registrador_generico
        GENERIC MAP(
            larguraDados => ADDR_WIDTH
        )
        PORT MAP(
            DIN    => MuxProxPC_PC,
            DOUT   => PC_ROM,
            ENABLE => '1',
            CLK    => clk,
            RST    => '0'
        );

    MuxProxPC : ENTITY work.mux_generico_2x1
        GENERIC MAP(
            larguraDados => ADDR_WIDTH
        )
        PORT MAP(
            entradaA_MUX => SomaUm_MuxProxPC,
            entradaB_MUX => enderecoJUMP,
            seletor_MUX  => muxJump,
            saida_MUX    => MuxProxPC_PC
        );
    
    somaUm : ENTITY work.soma_constante
        GENERIC MAP(
            larguraDados => ADDR_WIDTH,
            constante    => INCREMENTO
        )
        PORT MAP(
            entrada => PC_ROM,
            saida   => SomaUm_MuxProxPC
        );

    ROM : ENTITY work.memoria_rom
        GENERIC MAP(
            dataWidth => TOTAL_WIDTH,
            addrWidth => ADDR_WIDTH
        )
        PORT MAP(
            Endereco => PC_ROM,
            Dado     => Instrucao
        );
    
    mux_RAM_imediato : ENTITY work.mux_generico_2x1
        GENERIC MAP (
            larguraDados => DATA_WIDTH
        )
        PORT MAP (
            entradaA_MUX => Instrucao(DATA_WIDTH - 1 downto 0),
            entradaB_MUX => barramentoEntradaDados,
            seletor_MUX  => muxImedRam,
            saida_MUX    => saidaMuxImedRam
        );
    
    banco_registradores: ENTITY work.banco_registradores
        GENERIC MAP (
            larguraDados        => DATA_WIDTH,
            larguraEndBancoRegs => REG_WIDTH
        )
        PORT MAP (
            clk             => clk,
            enderecoA       => Instrucao(17 DOWNTO 15),
            enderecoB       => Instrucao(14 DOWNTO 12),
            enderecoC       => Instrucao(11 DOWNTO 9),
            dadoEscritaC    => saidaMuxULAImed_ou_RAM,
            escreveC        => escritaReg,

            saidaA          => saidaRegA,
            saidaB          => saidaRegB
        );

    ula : ENTITY work.ula
        GENERIC MAP(
            larguraDados => DATA_WIDTH
        )
        PORT MAP(
            entradaA => saidaRegA,
            entradaB => saidaRegB,
            saida    => saidaULA,
            seletor  => operacao,
            flagZero => flag_zero
        );

    mux_ULA_imediato_ou_ram : ENTITY work.mux_generico_2x1
        GENERIC MAP (
            larguraDados => DATA_WIDTH
        )
        PORT MAP (
            entradaA_MUX => saidaULA,
            entradaB_MUX => saidaMuxImedRam,
            seletor_MUX  => muxULAImedRam,
            saida_MUX    => saidaMuxULAImed_ou_RAM
        );

    decodificador_enderecos : ENTITY work.decodificador_enderecos
        GENERIC MAP (
            ADDR_WIDTH => ADDR_WIDTH 
        )
        PORT MAP (
            habilita => habilitaPerifericos,
            seletor => enderecoRAM
        );

    RAM : ENTITY work.memoria_ram
        GENERIC MAP(
            dataWidth => DATA_WIDTH,
            addrWidth => ADDR_WIDTH
        )
        PORT MAP(
            addr     => enderecoRAM,
            we       => habEscritaRAM,
            re       => habLeituraRAM,
            dado_in  => saidaRegA,
            dado_out => barramentoEntradaDados,
            clk      => clk,
            habilita => habilitaRAM
        );

    interface_switches: ENTITY work.interface_switches
        PORT MAP (
            sw_in => SW,
            sw_out => barramentoEntradaDados,
            habilita => habilitaSW
        );
    
    interface_buttons: ENTITY work.interface_buttons
        GENERIC MAP (
            ADDR_WIDTH => ADDR_WIDTH
        )
        PORT MAP (
            btn_in      => KEY,
            endereco    => enderecoRAM,
            btn_out     => barramentoEntradaDados,
            habilita    => habilitaBTN
        );

    interface_hex: ENTITY work.interface_hex
        GENERIC MAP (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        PORT MAP (
            HEX0 => HEX0,
            HEX1 => HEX1,
            HEX2 => HEX2,
            HEX3 => HEX3,
            HEX4 => HEX4,
            HEX5 => HEX5,
            endereco    => enderecoRAM,
            habilita    => habilitaHex,
            valor       => saidaRegA  
        );

    temporizador: ENTITY work.divisor_generico_interface
        GENERIC MAP (
            DATA_WIDTH => DATA_WIDTH
        )
        PORT MAP (
            clk                 => clk,
            habilitaLeitura     => habilitaTemp,
            limpaLeitura        => habilitaCLRTemp,
            leituraUmSegundo    => barramentoEntradaDados
        );

    opCode          <= opCodeLocal;
    programCounter  <= PC_ROM;

END ARCHITECTURE;
