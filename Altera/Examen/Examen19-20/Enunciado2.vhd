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

signal inicio: std_logic;
signal contador_base: integer range 0 to 5000000;
signal decimas_segundo: std_logic_vector (3 downto 0);
signal unidades_segundo: std_logic_vector (3 downto 0);
signal decenas_segundo: std_logic_vector (3 downto 0);
signal centenas_segundo: std_logic_vector (3 downto 0);

signal centenas_null: std_logic := '0'; -- Inicializamos a cero
signal decenas_null: std_logic := '0';
signal unidades_null: std_logic := '0';



begin

inicio<=v_bt(0);

process(g_clock_50, inicio)
begin
    if (inicio = '0') then
        contador_base <= 0;
    elsif (rising_edge(g_clock_50)) then
        if (contador_base = 5000000) then
            contador_base <= 0;
        else
            contador_base <= contador_base + 1;
        end if;
    end if;
end process;

process(g_clock_50, inicio)
begin
    if (inicio = '0') then
    decimas_segundo <= "0000";
    unidades_segundo <= "0000";
    decenas_segundo <= "0000";
    centenas_segundo <= "0000";
    elsif( rising_edge(g_clock_50) ) then
        if (contador_base = 5000000) then
            if ((unidades_segundo = "0001") and (decimas_segundo = "0010")) then
                decimas_segundo <=  decimas_segundo + 2;
            elsif (decimas_segundo = "1001") then
                decimas_segundo <= "0000";
                if (unidades_segundo = "1001") then
                    unidades_segundo <= "0000";
                    if (decenas_segundo = "1001") then 
                        decenas_segundo <= "0000";
                        if (centenas_segundo = "1001") then 
                            centenas_segundo <= "0000";
                            decimas_segundo <=  decimas_segundo + 1;
                        else 
                            centenas_segundo <= centenas_segundo + 1;
                        end if;
                    else 
                        decenas_segundo <= decenas_segundo + 1;
                    end if;
                else
                    unidades_segundo <=  unidades_segundo + 1;
                end if;
            else
                decimas_segundo <=  decimas_segundo + 1;
            end if;
        end if;
    end if;
end process;

process(g_clock_50, decimas_segundo, unidades_segundo, decenas_segundo, centenas_segundo)
begin
    if (rising_edge(g_clock_50)) then
        if (centenas_segundo = "0000") then
            centenas_null <= '1';
            if (decenas_segundo = "0000") then
                decenas_null <= '1';
                if (unidades_segundo = "0000") then
                    unidades_null <= '1';
                else 
                    unidades_null <= '0';
                end if;
            else 
                decenas_null <= '0';
            end if;
        else 
            centenas_null <= '0';
        end if;
    end if;
end process;


process(decimas_segundo, unidades_segundo, decenas_segundo, centenas_segundo)
begin
    case decimas_segundo is
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
    if (unidades_null = '1') then
        g_hex1<="1111111";
    else
        case unidades_segundo is
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
    if (decenas_null = '1') then
        g_hex2<="1111111";
    else
        case decenas_segundo is
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
    if (centenas_null = '1') then
        g_hex3<="1111111";
    else
        case centenas_segundo is
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
