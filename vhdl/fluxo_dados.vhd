LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fluxo_dados IS

    GENERIC (
        -- Tamanho do valor imediato determinado na 
        -- etapa de design do processador.
        DATA_WIDTH : NATURAL := 8;

        -- Tamanho dos endereços ROM/RAM determinado na 
        -- etapa de design do processador.
        ADDR_WIDTH : NATURAL := 9;

        -- Tamanho das instrucoes completas determinado na 
        -- etapa de design do processador.
        TOTAL_WIDTH: NATURAL := 22;

        -- Tamanho do endereço dos registadores, já que são 8
        -- registradores no banco de registradores o endereço deve ter
        -- no minimo 3 bits (2^3 = 8).
        -- Determinado no processo de design do processador de acordo com as necessidades do uso.
        REG_WIDTH: NATURAL := 3;

        -- Tamanho dos endereços ROM determinado na 
        -- etapa de design do processador.
        ROM_DATA_WIDTH : NATURAL := 9
    );

    PORT (
        -- SINAIS DE ENTRADA --
        -- Clock vindo da placa FPGA
        -- aproximadamente 50 MHz.
        clk             : IN std_logic;

        -- Pontos de controle concatenados, retornado pela unidade de controle
        -- e recebido aqui para habilitar os pontos de controle.
        palavraControle : IN std_logic_vector(9 DOWNTO 0);

        -- Switches da placa
        SW              : IN std_logic_vector(9 DOWNTO 0);

        -- Botoes da placa
        KEY             : IN std_logic_vector(3 DOWNTO 0);


        -- SINAIS DE SAÍDA --
        -- Codigo da operação vindo da instrução salva na ROM retornado aqui para ser
        -- usado na unidade de controle para auxiliar na criação da palavra de controle.
        -- Primeiros 4 bits da instrução.
        opCode          : OUT std_logic_vector(3 DOWNTO 0);

        -- Endereço da instrução que será retornada pela ROM.
        programCounter  : OUT std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);

        -- Dados que serão escritos nos displays hexadecimais.
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(6 DOWNTO 0);

        -- Sinal que recebe o valor da flag zero, retornada pela ULA no caso 
        -- de uma operação CMP a qual será retornada aqui e passada para a unidade 
        -- de controle para determinar se uma operação JE deve ser comprida.
        flag_zero_out   : OUT std_logic
    );

END ENTITY;

ARCHITECTURE main OF fluxo_dados IS

    -- SINAÍS INTERMEDIARIOS --
    -- Instrução completa de 22 bits (determinado na fase de design do processador)
    -- retornado pela memória ROM.
    SIGNAL Instrucao                  : std_logic_vector(TOTAL_WIDTH - 1 DOWNTO 0);

    -- Sinal do endereço da instrução na memória ROM recebido pelo program counter,
    -- e usado na memória ROM e no componente de soma constante.
    SIGNAL PC_ROM                     : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);

    -- Endereço da proxima instrução a ser executada retornada pela entidade
    -- soma constante que recebe o endereço atual e a constante 1.
    SIGNAL SomaUm_MuxProxPC           : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);

    -- Saida do mux o qual possui duas saidas possiveis: "SomaUm_MuxProxPC" ou o endereço
    -- na memória ROM vindo da instrução atual (bits 9-0).
    SIGNAL MuxProxPC_PC               : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0);

    -- Saida da ULA, usado no "MuxULAImed_ou_RAM" e recebido pela entidade ULA.
    SIGNAL saidaULA                   : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

    -- Sinal que possui os pontos de controles de habilitação dos IOs,
    -- recebido pelo decodificador de endereços dependendo do endereço presente na instrução
    -- (bits 9-0) utilizado nas interfaces dos IOs.
    SIGNAL habilitaPerifericos        : std_logic_vector(5 DOWNTO 0);

    -- Saida do mux "mux_imed_ram" o qual determina se o valor imediato ou valor da
    -- memória RAM será utilizado na entrada 1 da entidade "mux_ULA_imediato_ou_ram".
    SIGNAL saidaMuxImedRam            : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

    -- Saida do mux "mux_ULA_imediato_ou_ram" o qual possui a possibilidade de sair 
    -- o resultado da ULA ou a saida do "mux_imed_ram".
    SIGNAL saidaMuxULAImed_ou_RAM     : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

    -- Saidas do banco de registradores, respectivamente o valor do registrador A
    -- o qual possui o endereço nos bits 17-15 da instrução e do registrador B que
    -- possui o endereço nos bits 14-12 da instrução.
    SIGNAL saidaRegA, saidaRegB       : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

    -- Sinal que recebe o valor da flag zero retornado pela ULA.
    SIGNAL flag_zero_in               : std_logic;
    
    -- Barramento de dados que recebe dados dos IOs e memória RAM e é utilizado
    -- na memória RAM, temporizador e entidade "mux_imed_ram".
    SIGNAL barramentoEntradaDados     : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);


    -- ALIASES --
    -- Utilizados para facilitar leitura dos blocos de lógica.

    -- Opcode presente nos bits 21-18 da instrução retornada pela ROM.
    ALIAS opCodeLocal                 : std_logic_vector(3 DOWNTO 0) IS Instrucao(21 DOWNTO 18);

    -- Endereço da memória RAM para leitura ou escrita presente
    -- nos bits 9-0 da instrução retornada pela ROM.
    ALIAS enderecoRAM                 : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(ADDR_WIDTH - 1 DOWNTO 0);

    -- Endereço da memoria ROM presente nos bits 9-0 da instrução, para onde ocorrerá o JUMP caso 
    -- a instrução seja um JMP ou JE.
    ALIAS enderecoJUMP                : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(ADDR_WIDTH - 1 DOWNTO 0);

    -- Valor imediado presente na instrução.
    ALIAS imediato_entradaExtSinal    : std_logic_vector(ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(ADDR_WIDTH - 1 DOWNTO 0);

    -- Sinal presente na palavra controle o qual habilita
    -- o flip flop que salva a flag zero retornado pela ULA.
    ALIAS habilitaFlagZero            : std_logic IS palavraControle(9);

    -- Seletor do mux "MuxProxPC" o qual determina se a proxima instrução
    -- a ser executada será a do endereço seguinte ao atual ou o endereço presente
    -- na instrução (bits 9-0).
    ALIAS muxJump                     : std_logic IS palavraControle(8);

    -- Seletor do mux "mux_imed_ram" o qual determina se o valor imediato ou valor da
    -- memória RAM será utilizado na entrada 1 da entidade "mux_ULA_imediato_ou_ram".
    ALIAS muxImedRam                  : std_logic IS palavraControle(7);

    -- Sinal que habilita a possibilidade da saída do "mux_ULA_imediato_ou_ram" ser salvo no
	-- registrador C o qual endereço esta nos bits 11 - 9 da instrução.
    ALIAS escritaReg                  : std_logic IS palavraControle(6);

    -- Seletor da ULA o qual determina qual
    -- operação a ULA irá realizar.
    ALIAS operacao                    : std_logic_vector(2 DOWNTO 0) IS palavraControle(5 DOWNTO 3);

    -- Seletor presente na palavra controle do mux o qual determina se a saída da ULA ou
	-- a saída do "mux_imed_ram" será salvo no registrador C o qual endereço esta nos bits 11 - 9 da instrução.
    ALIAS muxULAImedRam               : std_logic IS palavraControle(2);

    -- Sinal presente na palavra controle que possibilita
	-- a leitura de valores da memória RAM caso seja habilitado.
    ALIAS habEscritaRAM               : std_logic IS palavraControle(1);

    -- Sinal presente na palavra controle que possibilita a
	-- escrita de valores na memória RAM caso seja habilitado.
    ALIAS habLeituraRAM               : std_logic IS palavraControle(0);

    -- Sinal presente no sinal "habilitaPerifericos" que
    -- habilita a limpa do do sinal do temporizador.
    ALIAS habilitaCLRTemp             : std_logic IS habilitaPerifericos(5);

    -- Sinal presente no sinal "habilitaPerifericos" que habilita os
    -- switches da placa FPGA.
    ALIAS habilitaSW                  : std_logic IS habilitaPerifericos(4);

    -- Sinal presente no sinal "habilitaPerifericos" que habilita os
    -- botões da placa FPGA.
    ALIAS habilitaBTN                 : std_logic IS habilitaPerifericos(3);

    -- Sinal presente no sinal "habilitaPerifericos" que habilita o temporizador.
    ALIAS habilitaTemp                : std_logic IS habilitaPerifericos(2);

    -- Sinal presente no sinal "habilitaPerifericos" que habilita os displays hexadecimais.
    ALIAS habilitaHex                 : std_logic IS habilitaPerifericos(1);

    -- Sinal presente no sinal "habilitaPerifericos" que habilita a 
    -- memória ROM.
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
            flagZero => flag_zero_in
        );

    flip_flop_flag_zero : ENTITY work.flip_flop_generico
        PORT MAP (
            DIN    => flag_zero_in,
            ENABLE => habilitaFlagZero,
            RST    => '0',
            CLK    => clk,
            DOUT   => flag_zero_out
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
            seletor => enderecoRAM,
            opcode => opCodeLocal
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
            habilitaLeitura     => (habilitaTemp or habilitaCLRTemp),
            limpaLeitura        => habilitaCLRTemp,
            leituraUmSegundo    => barramentoEntradaDados
        );

    opCode          <= opCodeLocal;
    programCounter  <= PC_ROM;

END ARCHITECTURE;
