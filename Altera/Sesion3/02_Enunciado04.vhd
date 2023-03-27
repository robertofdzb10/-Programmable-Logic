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
signal contador: std_logic_vector (3 downto 0);
signal contador_rebotes: integer range 0 to 50000;


begin

g_led(0)<=pulso_salida;
inicio<=v_bt(0);
pulsador<=v_bt(1);

process(inicio, g_clock_50)
begin
if (inicio='0') then 
   estado<="00";
elsif ( (g_clock_50 = '1') and (g_clock_50'event) ) then -- (Flanco de subida) Esta condición se evalúa como verdadera si la señal g_clock_50 es igual a '1' y ha ocurrido un evento en la señal g_clock_50. Un evento se produce en la señal g_clock_50 cuando cambia de valor, ya sea de '0' a '1' o de '1' a '0'. 
    case estado is
        when "00" => -- Estamos en Inicio
            if (pulsador = '1') then -- Mientras no pulsemos nos mantenemos en inicio
                estado<="00";
            else
                estado<="01"; -- Al pulsar pasamos al siguiente estado
            end if;
        when "01" => -- Estamos en Apretado
            if (pulsador = '0') then
                if  (contador_rebotes < 50000) then
                    contador_rebotes <= contador_rebotes + 1;
                elsif (contador_rebotes = 50000) then
                    contador_rebotes <= 0;
                    estado<="10";
                end if;
            else
                estado<="00";
            end if;
        when "10" => -- Estamos en Pulsado
            if (pulsador = '1') then -- Si el pulsado esta suelto, pasamos a suelto
                estado<="11";
            else
                estado<="10"; -- Sino nos quedamos en soltado
            end if;
        when others => 
            if (contador < "1001") then 
                contador <= contador + 1;
            else
                contador <= contador;
            end if;
            estado<="00";
    end case;
end if;
end process;

process(estado)
begin
case estado is
    when "00" => pulso_salida<='0';
    when "01" => pulso_salida<='1'; -- De manera que genere un único pulso, por pulsación, ya que en ese estado esta solo un pulso de reloj
    when "10" => pulso_salida<='0';
    when others => pulso_salida<='0';
end case;

case contador is
    when "0000" => g_hex0 <="0000001";
    when "0001" => g_hex0 <="1001111";
    when "0010" => g_hex0 <="0010010";
    when "0011" => g_hex0 <="0000110";
    when "0100" => g_hex0 <="1001100";
    when "0101" => g_hex0 <="0100100";
    when "0110" => g_hex0 <="1100000";
    when "0111" => g_hex0 <="0001111";
    when "1000" => g_hex0 <="0000000";
    when "1001" => g_hex0 <="0001100";
    when others => g_hex0 <="1111111";
end case;

end process;

end Behavioral;