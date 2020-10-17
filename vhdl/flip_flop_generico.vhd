LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY flip_flop_generico IS
    PORT (
        DIN, ENABLE, RST, CLK      : IN std_logic;
        DOUT                       : OUT std_logic
    );

END ENTITY;

ARCHITECTURE comportamento OF flip_flop_generico IS
BEGIN

    -- Update the register output on the clock's rising edge
    process (CLK)
        begin
        if (rising_edge(CLK)) then
            DOUT <= DIN;
        end if;
    end process;

END ARCHITECTURE;

