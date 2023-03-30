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
signal flt_1: integer range 0 to 500000000;
signal sal_1: std_logic;
signal flt_2: integer range 0 to 500000000;
signal bt: std_logic;
signal inicio: std_logic;
signal estado_1: std_logic_vector (2 downto 0);
signal estado_2: std_logic_vector (2 downto 0);

signal segundos_alarma: std_logic_vector (3 downto 0);
signal segundos_decenas_alarma: std_logic_vector (3 downto 0);
signal minutos_alarma: std_logic_vector (3 downto 0);
signal minutos_decenas_alarma: std_logic_vector (3 downto 0);
signal horas_alarma: std_logic_vector (3 downto 0);
signal horas_decenas_alarma: std_logic_vector (1 downto 0);
signal alarma_editada: std_logic;

signal segundos: std_logic_vector (3 downto 0);
signal segundos_decenas: std_logic_vector (3 downto 0);
signal minutos: std_logic_vector (3 downto 0);
signal minutos_decenas: std_logic_vector (3 downto 0);
signal horas: std_logic_vector (3 downto 0);
signal horas_decenas: std_logic_vector (1 downto 0);

signal config_alarma: std_logic;
signal bt_config_alarma: std_logic;
signal contador_base: integer range 0 to 50000000;

signal borrar_alarma: std_logic;
signal alarma_blink: std_logic;




begin

inicio<=v_bt(0);
bt<=v_bt(1);
borrar_alarma<=v_bt(3);
bt_config_alarma<=v_bt(2);
g_led(0)<= config_alarma;
g_led(1)<=alarma_blink;



process(inicio, bt, g_clock_50) -- Autómata para poner la alarma
begin
    if (inicio = '0') then
        estado_1 <= "000";
        flt_1 <= 0;
        sal_1 <= '0';
    elsif ( rising_edge(g_clock_50) ) then
        case estado_1 is
            when "000" =>
                flt_1 <= 0;
                sal_1 <= '0';
                if (bt = '0') then
                    estado_1 <= "001";
                elsif (bt = '1') then
                    estado_1 <= "000";
                end if;
            when "001" =>
                flt_1 <= flt_1 + 1;
                sal_1 <= '0';
                if ( (bt = '0') and (flt_1 < 50000) ) then
                    estado_1 <= "001";
                elsif ( (bt = '0') and (flt_1 = 50000) ) then
                    estado_1 <= "010";
                elsif (bt = '1') then
                    estado_1 <= "000";
                end if;
            when "010" =>
                flt_1 <= flt_1 + 1;
                sal_1 <= '0';
                if ( (bt = '0') and (flt_1 < 50000000) ) then
                    estado_1 <= "010";
                elsif ( (bt = '0') and (flt_1 = 50000000) ) then
                    estado_1 <= "100";
                elsif (bt = '1') then
                    estado_1 <= "011";
                end if;
            when "011" =>
                flt_1 <= 0;
                sal_1 <= '1';
                estado_1 <= "000";
            when "100" =>
                flt_1 <= 0;
                sal_1 <= '1';
                estado_1 <= "101";
            when "101" =>
                flt_1 <= flt_1 + 1;
                sal_1 <= '0';
                if ( (bt = '0') and (flt_1 < 5000000 ) ) then
                    estado_1 <= "101";
                elsif ( (bt = '0') and (flt_1 = 5000000 ) ) then
                    estado_1 <= "100";
                elsif (bt = '1') then
                    estado_1 <= "011";
                end if;
            when others =>
                estado_1 <= "000";
                flt_1 <= 0;
                sal_1 <= '0';
        end case;
    end if;
end process;

process(inicio, bt_config_alarma, g_clock_50) -- Autómata para el botón de cambio de modo
begin
    if (inicio = '0') then
        estado_2 <= "000";
        flt_2 <= 0;
        config_alarma <= '0';
        alarma_editada <= '0';
    elsif ( rising_edge(g_clock_50) ) then
        case estado_2 is
            when "000" =>
                flt_2 <= 0;
                if (bt_config_alarma = '0') then
                    estado_2 <= "001";
                elsif (bt_config_alarma = '1') then
                    estado_2 <= "000";
                end if;
            when "001" =>
                flt_2 <= flt_2 + 1;
                if ( (bt_config_alarma = '0') and (flt_2 < 50000) ) then
                    estado_2 <= "001";
                elsif ( (bt_config_alarma = '0') and (flt_2 = 50000) ) then
                    estado_2 <= "010";
                elsif (bt_config_alarma = '1') then
                    estado_2 <= "000";
                end if;
            when "010" =>
                flt_2 <= 0;
                if ( (bt_config_alarma = '0') ) then
                    estado_2 <= "010";
                elsif (bt_config_alarma = '1') then
                    estado_2 <= "011";
                end if;
            when "011" =>
                flt_2 <= 0;
                estado_2 <= "000";
                config_alarma <= not config_alarma;
                if (config_alarma = '0') then --Hemos ya editado la alarma
                    alarma_editada <= '1';
                else
                end if;
            when others =>
                estado_2 <= "000";
                flt_2 <= 0;
        end case;
    end if;
end process;


process(inicio,g_clock_50)
begin
    if (inicio = '0') then
        contador_base <= 0;
    elsif (rising_edge (g_clock_50)) then
        if (contador_base < 50000000) then
            contador_base <= contador_base + 1;
        else 
            contador_base <= 0;
        end if;
    end if;
end process;

process(inicio, sal_1, g_clock_50, bt_config_alarma)
begin
    if (inicio = '0') then
        segundos_alarma <= "0000";
        segundos_decenas_alarma <= "0000";
        minutos_alarma  <= "0000";
        minutos_decenas_alarma  <= "0000";
        horas_alarma <= "0000";
        horas_decenas_alarma <= "00";
        segundos <= "0000";
        segundos_decenas <= "0000";
        minutos  <= "0000";
        minutos_decenas  <= "0000";
        horas <= "0000";
        horas_decenas <= "00";
    elsif ((borrar_alarma = '0')) then 
        segundos_alarma <= "0000";
        segundos_decenas_alarma <= "0000";
        minutos_alarma  <= "0000";
        minutos_decenas_alarma  <= "0000";
        horas_alarma <= "0000";
        horas_decenas_alarma <= "00";
    elsif (rising_edge (g_clock_50)) then -- Va por flancos de reloj, de manera que solo entra una vez aquí, por que sol oesta sal_1=1 activo un flanco de reloj
        if ((sal_1 = '1') and (config_alarma = '1')) then
            if ( segundos_alarma = "1001" ) then 
                segundos_alarma <= "0000";
                if (segundos_decenas_alarma = "0101" ) then
                    segundos_decenas_alarma <= "0000";
                    if (minutos_alarma = "1001") then
                        minutos_alarma <= "0000";
                        if  (minutos_decenas_alarma = "0101" ) then
                         minutos_decenas_alarma <= "0000";
                            if ( (horas_decenas_alarma = "10") and (horas_alarma = "0011"))  then
                                horas_alarma <= "0000";
                                horas_decenas_alarma <= "00";
                            elsif ( horas_alarma = "1001")  then
                                horas_alarma <= "0000";
                                horas_decenas_alarma <= horas_decenas_alarma + 1;
                            else
                                horas_alarma <= horas_alarma + 1;
                            end if;
                        else
                         minutos_decenas_alarma <= minutos_decenas_alarma + 1;
                        end if;
                    else
                        minutos_alarma <= minutos_alarma + 1;
                    end  if;
                else
                    segundos_decenas_alarma <= segundos_decenas_alarma + 1;
                end if;
            else 
                segundos_alarma <= segundos_alarma + 1;
            end if;
        elsif (contador_base = 50000000) then
            if ( segundos = "1001" ) then 
                segundos <= "0000";
                if (segundos_decenas = "0101" ) then
                    segundos_decenas <= "0000";
                    if (minutos = "1001") then
                        minutos <= "0000";
                        if (minutos_decenas = "0101" ) then
                            minutos_decenas <= "0000";
                            if ( (horas_decenas = "10") and (horas = "0011"))  then
                                horas <= "0000";
                                horas_decenas <= "00";
                            elsif ( horas = "1001")  then
                                horas <= "0000";
                                horas_decenas <= horas_decenas + 1;
                            else
                                horas <= horas + 1;
                            end if;
                        else
                            minutos_decenas <= minutos_decenas + 1;
                        end if;
                    else
                        minutos <= minutos + 1;
                    end  if;
                else
                    segundos_decenas <= segundos_decenas + 1;
                end if;
            else 
                segundos <= segundos + 1;
            end if;
        else
        end if;
    end if;
end process;

process(g_clock_50, contador_base, segundos_alarma,segundos_decenas_alarma,minutos_alarma, minutos_decenas_alarma, horas_alarma, horas_decenas_alarma, segundos,segundos_decenas,minutos, minutos_decenas, horas, horas_decenas)
begin
    if (inicio = '0') then
        alarma_blink <= '0';
    elsif (rising_edge(g_clock_50)) then
        if ((alarma_editada = '1') and ( segundos = segundos_alarma ) and (segundos_decenas = segundos_decenas_alarma) and (minutos = minutos_alarma) and (minutos_decenas = minutos_decenas_alarma) and  (horas = horas_alarma) and (horas_decenas = horas_decenas_alarma)) then
            if (contador_base = 50000000) then
                alarma_blink <= not alarma_blink;
            end if;
        end if;
    else
    end if;
end process;

process(segundos_alarma,segundos_decenas_alarma,minutos_alarma, minutos_decenas_alarma, horas_alarma, horas_decenas_alarma, segundos,segundos_decenas,minutos, minutos_decenas, horas, horas_decenas)
begin
    if (config_alarma = '1') then
        case segundos_alarma is
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
            when others => g_hex0 <="0000001";
        end case;

        case segundos_decenas_alarma is
            when "0000" => g_hex1 <="0000001";
            when "0001" => g_hex1 <="1001111";
            when "0010" => g_hex1 <="0010010";
            when "0011" => g_hex1 <="0000110";
            when "0100" => g_hex1 <="1001100";
            when "0101" => g_hex1 <="0100100";
            when "0110" => g_hex1 <="1100000";
            when "0111" => g_hex1 <="0001111";
            when "1000" => g_hex1 <="0000000";
            when "1001" => g_hex1 <="0001100";
            when others => g_hex1 <="0000001";
        end case;

        case minutos_alarma is
            when "0000" => g_hex2 <="0000001";
            when "0001" => g_hex2 <="1001111";
            when "0010" => g_hex2 <="0010010";
            when "0011" => g_hex2 <="0000110";
            when "0100" => g_hex2 <="1001100";
            when "0101" => g_hex2 <="0100100";
            when "0110" => g_hex2 <="1100000";
            when "0111" => g_hex2 <="0001111";
            when "1000" => g_hex2 <="0000000";
            when "1001" => g_hex2 <="0001100";
            when others => g_hex2 <="0000001";
        end case;

        case minutos_decenas_alarma is
            when "0000" => g_hex3 <="0000001";
            when "0001" => g_hex3 <="1001111";
            when "0010" => g_hex3 <="0010010";
            when "0011" => g_hex3 <="0000110";
            when "0100" => g_hex3 <="1001100";
            when "0101" => g_hex3 <="0100100";
            when "0110" => g_hex3 <="1100000";
            when "0111" => g_hex3 <="0001111";
            when "1000" => g_hex3 <="0000000";
            when "1001" => g_hex3 <="0001100";
            when others => g_hex3 <="0000001";
        end case;

        case horas_alarma is
            when "0000" => g_hex4 <="0000001";
            when "0001" => g_hex4 <="1001111";
            when "0010" => g_hex4 <="0010010";
            when "0011" => g_hex4 <="0000110";
            when "0100" => g_hex4 <="1001100";
            when "0101" => g_hex4 <="0100100";
            when "0110" => g_hex4 <="1100000";
            when "0111" => g_hex4 <="0001111";
            when "1000" => g_hex4 <="0000000";
            when "1001" => g_hex4 <="0001100";
            when others => g_hex4 <="0000001";
        end case;

        case horas_decenas_alarma is
            when "00" => g_hex5 <="0000001";
            when "01" => g_hex5 <="1001111";
            when "10" => g_hex5 <="0010010";
            when others => g_hex5 <="0000001";
        end case;
    else
        case segundos is
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
            when others => g_hex0 <="0000001";
        end case;

        case segundos_decenas is
            when "0000" => g_hex1 <="0000001";
            when "0001" => g_hex1 <="1001111";
            when "0010" => g_hex1 <="0010010";
            when "0011" => g_hex1 <="0000110";
            when "0100" => g_hex1 <="1001100";
            when "0101" => g_hex1 <="0100100";
            when "0110" => g_hex1 <="1100000";
            when "0111" => g_hex1 <="0001111";
            when "1000" => g_hex1 <="0000000";
            when "1001" => g_hex1 <="0001100";
            when others => g_hex1 <="0000001";
        end case;

        case minutos is
            when "0000" => g_hex2 <="0000001";
            when "0001" => g_hex2 <="1001111";
            when "0010" => g_hex2 <="0010010";
            when "0011" => g_hex2 <="0000110";
            when "0100" => g_hex2 <="1001100";
            when "0101" => g_hex2 <="0100100";
            when "0110" => g_hex2 <="1100000";
            when "0111" => g_hex2 <="0001111";
            when "1000" => g_hex2 <="0000000";
            when "1001" => g_hex2 <="0001100";
            when others => g_hex2 <="0000001";
        end case;

        case minutos_decenas is
            when "0000" => g_hex3 <="0000001";
            when "0001" => g_hex3 <="1001111";
            when "0010" => g_hex3 <="0010010";
            when "0011" => g_hex3 <="0000110";
            when "0100" => g_hex3 <="1001100";
            when "0101" => g_hex3 <="0100100";
            when "0110" => g_hex3 <="1100000";
            when "0111" => g_hex3 <="0001111";
            when "1000" => g_hex3 <="0000000";
            when "1001" => g_hex3 <="0001100";
            when others => g_hex3 <="0000001";
        end case;

        case horas is
            when "0000" => g_hex4 <="0000001";
            when "0001" => g_hex4 <="1001111";
            when "0010" => g_hex4 <="0010010";
            when "0011" => g_hex4 <="0000110";
            when "0100" => g_hex4 <="1001100";
            when "0101" => g_hex4 <="0100100";
            when "0110" => g_hex4 <="1100000";
            when "0111" => g_hex4 <="0001111";
            when "1000" => g_hex4 <="0000000";
            when "1001" => g_hex4 <="0001100";
            when others => g_hex4 <="0000001";
        end case;

        case horas_decenas is
            when "00" => g_hex5 <="0000001";
            when "01" => g_hex5 <="1001111";
            when "10" => g_hex5 <="0010010";
            when others => g_hex5 <="0000001";
        end case;
    end if;

end process;

end Behavioral;