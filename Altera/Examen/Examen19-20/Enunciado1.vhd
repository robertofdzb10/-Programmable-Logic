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
signal unidades: std_logic_vector (3 downto 0);
signal decenas: std_logic_vector (3 downto 0);
signal centenas: std_logic_vector (3 downto 0);
signal millares: std_logic_vector (3 downto 0);
signal millares_null: std_logic := '0'; -- Inicializamos a cero
signal centenas_null: std_logic := '0';
signal decenas_null: std_logic := '0';

begin

inicio<=v_bt(0);
unidades<=v_sw(3 downto 0);
decenas<=v_sw(7 downto 4);
centenas<=v_sw(11 downto 8);
millares<=v_sw(15 downto 12);

process(unidades, decenas, centenas, millares)
begin
    if (inicio = '0') then
        millares_null <= '0';
        centenas_null <= '0';
        decenas_null <= '0';
    end if;
    if (millares = "0000") then
        millares_null <= '1';
        if (centenas = "0000") then
            centenas_null <= '1';
            if (decenas = "0000") then
                decenas_null <= '1';
            else 
                decenas_null <= '0';
            end if;
        else 
            centenas_null <= '0';
        end if;
    else 
        millares_null <= '0';
    end if;
end process;


process(unidades, decenas, centenas, millares, millares_null, centenas_null, decenas_null)
begin
    case unidades is
        when "0000" => g_hex0<="0000001";
        when "0001" => g_hex0<="1001111";
        when "0010" => g_hex0<="0010010";
        when "0011" => g_hex0<="0000110";
        when "0100" => g_hex0<="1001100";
        when "0101" => g_hex0<="0100100";
        when "0110" => g_hex0<="1100000";
        when "0111" => g_hex0<="0001111";
        when "1000" => g_hex0<="0000000";
        when "1001" => g_hex0<="0001100";
        when others => g_hex0<="1111111";
    end case;
    if (decenas_null = '1') then
        g_hex1<="1111111";
    else
        case decenas is
            when "0000" => g_hex1<="0000001";
            when "0001" => g_hex1<="1001111";
            when "0010" => g_hex1<="0010010";
            when "0011" => g_hex1<="0000110";
            when "0100" => g_hex1<="1001100";
            when "0101" => g_hex1<="0100100";
            when "0110" => g_hex1<="1100000";
            when "0111" => g_hex1<="0001111";
            when "1000" => g_hex1<="0000000";
            when "1001" => g_hex1<="0001100";
            when others => g_hex1<="1111111";
        end case;
    end if;
    if (centenas_null = '1') then
        g_hex2<="1111111";
    else
        case centenas is
            when "0000" => g_hex2<="0000001";
            when "0001" => g_hex2<="1001111";
            when "0010" => g_hex2<="0010010";
            when "0011" => g_hex2<="0000110";
            when "0100" => g_hex2<="1001100";
            when "0101" => g_hex2<="0100100";
            when "0110" => g_hex2<="1100000";
            when "0111" => g_hex2<="0001111";
            when "1000" => g_hex2<="0000000";
            when "1001" => g_hex2<="0001100";
            when others => g_hex2<="1111111";
        end case;
    end if;
    if (millares_null = '1') then
        g_hex3<="1111111";
    else
        case millares is
            when "0000" => g_hex3<="0000001";
            when "0001" => g_hex3<="1001111";
            when "0010" => g_hex3<="0010010";
            when "0011" => g_hex3<="0000110";
            when "0100" => g_hex3<="1001100";
            when "0101" => g_hex3<="0100100";
            when "0110" => g_hex3<="1100000";
            when "0111" => g_hex3<="0001111";
            when "1000" => g_hex3<="0000000";
            when "1001" => g_hex3<="0001100";
            when others => g_hex3<="1111111";
        end case;
    end if;
    g_hex4<="1111111";
    g_hex5<="1111111";
end process;
 
end Behavioral;
