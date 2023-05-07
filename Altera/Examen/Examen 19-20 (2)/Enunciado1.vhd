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
--aqui comienzan las signals

--signals del multiplexado del 7-segmentos
signal inicio: std_logic;
signal unidades: std_logic_vector (1 downto 0);
signal decenas:  std_logic_vector (1 downto 0);
signal centenas:  std_logic_vector (1 downto 0);
signal millares:  std_logic_vector (1 downto 0);

begin

inicio<=v_bt(0);
unidades<=v_sw(1 downto 0);
decenas<=v_sw(3 downto 2);
centenas<=v_sw(5 downto 4);
millares<=v_sw(7 downto 6);



--descripcion del decodificador BCD-7segmentos
process(unidades,decenas,centenas,millares)
begin
    g_hex4<="1111111";
    g_hex5<="1111111";
    case unidades is
    when "00" => g_hex0<="0000001";
    when "01" => g_hex0<="1001111";
    when "10" => g_hex0<="0010010";
    when "11" => g_hex0<="0000110";
    when others => g_hex0<="1111111";
    end case;
if decenas > "0000" or centenas > "0000"  or millares > "0000" then
    case decenas is
    when "00" => g_hex1<="0000001";
    when "01" => g_hex1<="1001111";
    when "10" => g_hex1<="0010010";
    when "11" => g_hex1<="0000110";
    when others => g_hex1<="1111111";
    end case;
else 
    g_hex1<="1111111";
end if;
if centenas > "0000" or millares > "0000" then
    case centenas is
    when "00" => g_hex2<="0000001";
    when "01" => g_hex2<="1001111";
    when "10" => g_hex2<="0010010";
    when "11" => g_hex2<="0000110";
    when others => g_hex2<="1111111";
    end case;
else 
    g_hex2<="1111111";
end if;
if millares > "0000" then
    case millares is
    when "00" => g_hex3<="0000001";
    when "01" => g_hex3<="1001111";
    when "10" => g_hex3<="0010010";
    when "11" => g_hex3<="0000110";
    when others => g_hex3<="1111111";
    end case;
else 
    g_hex3<="1111111";
end if;
end process;
 
end Behavioral;
