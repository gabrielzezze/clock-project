LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memoria_rom IS

    GENERIC (
        dataWidth : NATURAL := 8;
        addrWidth : NATURAL := 3
    );
    PORT (
        Endereco : IN std_logic_vector (addrWidth - 1 DOWNTO 0);
        Dado     : OUT std_logic_vector (dataWidth - 1 DOWNTO 0)
    );

END ENTITY;

ARCHITECTURE assincrona OF memoria_rom IS

    TYPE blocoMemoria IS ARRAY(0 TO 2 ** addrWidth - 1) OF std_logic_vector(dataWidth - 1 DOWNTO 0);

    CONSTANT Jump      : std_logic_vector(3 DOWNTO 0) := "0000";
    CONSTANT Load      : std_logic_vector(3 DOWNTO 0) := "0001";
    CONSTANT Store     : std_logic_vector(3 DOWNTO 0) := "0010";
    CONSTANT AddAccMem : std_logic_vector(3 DOWNTO 0) := "0011";
    CONSTANT SubAccMem : std_logic_vector(3 DOWNTO 0) := "0100";

    FUNCTION initMemory
        RETURN blocoMemoria IS VARIABLE tmp : blocoMemoria := (OTHERS => (OTHERS => '0'));
        BEGIN
        tmp(0) := "0011001001001000000000"; 
        tmp(1) := "0011010010010000000000"; 
        tmp(2) := "0011011011011000000001"; 
        tmp(3) := "0100000000000000001000"; 
        tmp(4) := "0101000000000000000101"; 
        tmp(5) := "0111000001000000000000"; 
        tmp(6) := "1001000000000000000011"; 
        tmp(7) := "0101000000000000001001"; 
        tmp(8) := "0101011011011000000111"; 
        tmp(9) := "0010011011011000000000"; 
        tmp(10) := "1000000000000000000011";    
         
            RETURN tmp;
        END initMemory;

    SIGNAL memROM : blocoMemoria := initMemory;
BEGIN
    Dado <= memROM (to_integer(unsigned(Endereco)));

END ARCHITECTURE;