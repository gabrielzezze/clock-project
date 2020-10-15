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

        -- OUT
        opCode          : OUT std_logic_vector(3 DOWNTO 0);
        saidaAcumulador : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
        programCounter  : OUT std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
        flag_zero       : OUT std_logic
    );

END ENTITY;

ARCHITECTURE main OF fluxo_dados IS
    SIGNAL Instrucao                  : std_logic_vector(TOTAL_WIDTH - 1 DOWNTO 0);
    SIGNAL PC_ROM                     : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL SomaUm_MuxProxPC           : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL MuxProxPC_PC               : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL muxULAImed_Acumulador      : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL Acumulador_ULA_A           : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaULA                   : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL DadoLidoRAM_ULA_B          : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaExtSinal_muxULAImed_0 : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

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

    -- RAM : ENTITY work.memoriaRAM
    --     GENERIC MAP(
    --         dataWidth => DATA_WIDTH,
    --         addrWidth => ADDR_WIDTH)
    --     PORT MAP(
    --         addr     => enderecoRAM,
    --         we       => habEscritaMEM,
    --         dado_in  => Acumulador_ULA_A,
    --         dado_out => DadoLidoRAM_ULA_B,
    --         clk      => clk
    --     );

    opCode          <= opCodeLocal;
    programCounter  <= PC_ROM;

END ARCHITECTURE;
