library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all; -- Revisar si se ha de cambiar

entity main is
    port (
    g_clock_50: in std_logic;
    v_sw  : in std_logic_vector (9 downto 0); 
    v_bt  : in std_logic_vector (3 downto 0); 
    g_led : out std_logic_vector(9 downto 0); 
    g_hex0 : out std_logic_vector(0 to 6); 
    g_hex1 : out std_logic_vector(0 to 6);
    g_hex2 : out std_logic_vector(0 to 6);
    g_hex3 : out std_logic_vector(0 to 6);
    g_hex4 : out std_logic_vector(0 to 6);
    g_hex5 : out std_logic_vector(0 to 6) 
    );
end main;

architecture Behavioral of main is

-- Editable

signal inicio: std_logic;
signal pulsador: std_logic;
signal pulso_salida: std_logic;
signal estado: std_logic_vector (1 downto 0);
signal revision: std_logic;


begin

g_led(0)<=revision;
inicio<=v_bt(0);
pulsador<=v_bt(1);

process(inicio, g_clock_50)
begin
if inicio='1' then 
   estado<="00";
elsif (g_clock_50 ='1') and (g_clock_50'event) then -- (Flanco de subida) Esta condición se evalúa como verdadera si la señal g_clock_50 es igual a '1' y ha ocurrido un evento en la señal g_clock_50. Un evento se produce en la señal g_clock_50 cuando cambia de valor, ya sea de '0' a '1' o de '1' a '0'.
    case estado is
        when "00" => -- Estamos en Inicio
                if pulsador = '1' then -- Mientras no pulsemos nos mantenemos en inicio
                estado<="00";
            else
                estado<="01"; -- Al pulsar pasamos al siguiente estado
            end if;
        when "01" => -- Estamos en Apretado
                estado<="10"; -- Pasamos en ese flanco a soltado
        when "10" => -- Estamos en Soltado
                if pulsador='1' then -- Si el pulsado esta suelto, pasamos a inicio
                estado<="00";
            else
                estado<="10"; -- Sino nos quedamos en soltado
            end if;
        when others => estado<="00";
   end case;
end if;
end process;

process(estado)
begin
case estado is
    when "00" => pulso_salida<='0';
    when "01" => pulso_salida<='1';
    when "10" => 
                pulso_salida<='0';
                pulso_salida <= not revision;
    when others => pulso_salida<='0';
end case;
end process;

end Behavioral;

