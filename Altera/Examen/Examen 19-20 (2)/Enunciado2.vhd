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
signal cont_base: integer range 0 to 5000000;
signal decimas: std_logic_vector (3 downto 0);
signal unidades: std_logic_vector (3 downto 0);
signal decenas: std_logic_vector (3 downto 0);
signal centenas: std_logic_vector (3 downto 0);


signal sal_mux: std_logic_vector (3 downto 0);


begin

inicio<=v_bt(0);

process(g_clock_50)
begin
    if (inicio = '0') then
        cont_base <= 0;
    elsif (rising_edge(g_clock_50)) then
        if (cont_base < 5000000 ) then
            cont_base <= cont_base + 1;
        else
            cont_base <= 0;
        end if;
    end if;
end process;


process(g_clock_50, inicio)
begin
    if (inicio = '0') then
        decimas <= "0000";
        unidades <= "0000";
        decenas <= "0000";
        centenas <= "0000";
    elsif (rising_edge(g_clock_50)) then
        if (cont_base = 5000000) then
            if (decimas = "1001") then 
                decimas <= "0000";
                if (unidades = "1001") then
                    unidades <= "0000";
                    if (decenas = "1001") then
                        decenas <= "0000";
                        if (centenas = "1001") then
                            centenas <= "0000";
                        else 
                            centenas <= centenas + 1;
                        end if;
                    else
                        decenas <= decenas + 1;
                    end if;
                else
                    unidades <= unidades + 1;
                end if;
            else 
                decimas <= decimas + 1;
            end if;
        end if;
    end if;
end process;



--descripcion del decodificador BCD-7segmentos
process(decimas, unidades, decenas, centenas)
begin
    g_hex4<="1111111";
    g_hex5<="1111111";
    case decimas is
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
        when others => g_hex0<="0110000";
    end case;
if (unidades > "0000" or decenas > "0000" or centenas > "0000") then
    case unidades is
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
        when others => g_hex1<="0110000";
    end case;
else 
    g_hex1<="1111111";
end if;
if (decenas > "0000" or centenas > "0000") then
    case decenas is
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
        when others => g_hex2<="0110000";
    end case;
else 
    g_hex2<="1111111";
end if;
if (centenas > "0000") then
    case centenas is
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
        when others => g_hex3<="0110000";
    end case;
else 
    g_hex3<="1111111";
end if;
end process;
 
end Behavioral;
