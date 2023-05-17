Código VHDL
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity HCSR_04_22_23 is
port(
clk: in std_logic; -- al ser con ARM es de 100 MHz, no de 125 MHz
inicio: in std_logic;
echo: in std_logic;
trigger: out std_logic;
distancia_cm_bit: out std_logic_vector (8 downto 0)
);

end HCSR_04_22_23;

architecture Behavioral of HCSR_04_22_23 is

signal reloj_1MHz: integer range 0 to 100;
type estado_nombre is (reset, pulso, detec_echo, medida);
signal estado: estado_nombre:=reset;
signal cont_tiempo_us: integer range 0 to 9; --100000;
signal cont_echo_us: integer range 0 to 100000;
signal distancia_cm: integer range 0 to 450;


begin

process(inicio, clk)
begin
if inicio='1' then
    reloj_1MHz<=0;
elsif rising_edge(clk) then
    if reloj_1MHz=(100-1) then
        reloj_1MHz<=0;
    else
        reloj_1MHz<=reloj_1MHz+1;
    end if;        
end if;
end process;

process(clk, inicio)
begin
if inicio='1' then
    estado<=reset;
    cont_tiempo_us<=0;
    cont_echo_us<=0;
    distancia_cm_bit<="000000000";
elsif rising_edge(clk) then
    if reloj_1MHz=0 then
        case estado is 
        when reset =>
            distancia_cm<=cont_echo_us/58;
            distancia_cm_bit<=std_logic_vector(to_unsigned(distancia_cm,9));
            cont_tiempo_us<=0;
            cont_echo_us<=0;
            estado<=pulso;
        when pulso =>
            cont_tiempo_us<=cont_tiempo_us+1;
            cont_echo_us<=0;
            if cont_tiempo_us=9 then
                estado<=detec_echo;
            end if;                 
        when detec_echo => 
            cont_tiempo_us<=cont_tiempo_us+1;
            if echo='1' then
                cont_echo_us<=cont_echo_us+1;
                estado<=detec_echo;
            else
                estado<=reset;--medida;        
            end if;
        when others =>                                              
           cont_tiempo_us<=0;
           cont_echo_us<=0;
           estado<=reset; 
        end case;
    end if;
end if;         
end process;
                   
process(estado)
begin    
case (estado) is
when reset => trigger<='0';
when pulso => trigger<='1';
when detec_echo => trigger<='0';
when medida => trigger<='0';
when others => trigger<='0';
end case;
end process;

end Behavioral;
