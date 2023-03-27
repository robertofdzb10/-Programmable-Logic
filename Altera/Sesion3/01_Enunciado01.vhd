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
if inicio='0' then -- Botón reinicio
    estado<="00";
elsif rising_edge(g_clock_50) then
    case estado is
    when "00" =>
        if pulsador='1' then -- Sino esta pulsado
            estado<="00";
        else
            estado<="01"; -- Si esta pulsado vamos al estado 1
        end if;           
    when "01" =>
        if pulsador ='1' then -- Si se deja de pulsar vamos al último estado
            estado<="10";
        else
            estado<="01"; -- Mientras se pulse nos mantenemos en ese estado
        end if;
    when "10" => -- Cuando estemos en el último estado, aguantamos solo un pulso de reloj
        estado<="00";
    when others =>
        estado<="00";
    end case;
end if;
end process; 

process(estado)
begin
case estado is
when "00" => pulso_salida<='0'; -- Convertimos el pulso de entrada en un pulso de salida de duración un pulso de reloj
when "01" => pulso_salida<='0';
when "10" => 
            pulso_salida<='1';
            revision<= not revision;
when others => pulso_salida<='0';
end case;
end process;


end Behavioral;
