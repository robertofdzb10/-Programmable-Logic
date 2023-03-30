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
signal flt: integer range 0 to 500000000;
signal sal: std_logic;
signal bt: std_logic;
signal inicio: std_logic;
signal estado: std_logic_vector (2 downto 0);

signal segundos: std_logic_vector (3 downto 0);
signal segundos_decenas: std_logic_vector (3 downto 0);
signal minutos: std_logic_vector (3 downto 0);
signal minutos_decenas: std_logic_vector (3 downto 0);
signal horas: std_logic_vector (3 downto 0);
signal horas_decenas: std_logic_vector (1 downto 0);

signal inicio_alarma: std_logic;
signal bt_inicio_alarma: std_logic;
signal contador_base: integer range 0 to 50000000;



begin

inicio<=v_bt(0);
bt<=v_bt(1);
bt_inicio_alarma<=v_bt(2);
g_led(2 downto 0)<= estado;
g_led(4)<= inicio_alarma;

process(inicio, bt, g_clock_50) -- Autómata para poner la alarma
begin
    if (inicio = '0') then
        estado <= "000";
        flt <= 0;
        sal <= '0';
    elsif ( rising_edge(g_clock_50) ) then
        case estado is
            when "000" =>
                flt <= 0;
                sal <= '0';
                if (bt = '0') then
                    estado <= "001";
                elsif (bt = '1') then
                    estado <= "000";
                end if;
            when "001" =>
                flt <= flt + 1;
                sal <= '0';
                if ( (bt = '0') and (flt < 50000) ) then
                    estado <= "001";
                elsif ( (bt = '0') and (flt = 50000) ) then
                    estado <= "010";
                elsif (bt = '1') then
                    estado <= "000";
                end if;
            when "010" =>
                flt <= flt + 1;
                sal <= '0';
                if ( (bt = '0') and (flt < 50000000) ) then
                    estado <= "010";
                elsif ( (bt = '0') and (flt = 50000000) ) then
                    estado <= "100";
                elsif (bt = '1') then
                    estado <= "011";
                end if;
            when "011" =>
                flt <= 0;
                sal <= '1';
                estado <= "000";
            when "100" =>
                flt <= 0;
                sal <= '1';
                estado <= "101";
            when "101" =>
                flt <= flt + 1;
                sal <= '0';
                if ( (bt = '0') and (flt < 5000000 ) ) then
                    estado <= "101";
                elsif ( (bt = '0') and (flt = 5000000 ) ) then
                    estado <= "100";
                elsif (bt = '1') then
                    estado <= "011";
                end if;
            when others =>
                estado <= "000";
                flt <= 0;
                sal <= '0';
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

process(inicio, sal, g_clock_50, bt_inicio_alarma)
begin
    if (inicio = '0') then
        segundos <= "0000";
        segundos_decenas <= "0000";
        minutos  <= "0000";
        minutos_decenas  <= "0000";
        horas <= "0000";
        horas_decenas <= "00";
        inicio_alarma <= '0';
    elsif (bt_inicio_alarma = '0') then
        inicio_alarma <= '1';
    elsif (rising_edge (g_clock_50)) then -- Va por flancos de reloj, de manera que solo entra una vez aquí, por que sol oesta sal=1 activo un flanco de reloj
        if (sal = '1') then
            if ( segundos = "1001" ) then 
                segundos <= "0000";
                if (segundos_decenas = "0101" ) then
                    segundos_decenas <= "0000";
                    if (minutos = "1001") then
                        minutos <= "0000";
                        if (minutos_decenas = "0101" ) then
                            minutos_decenas <= "0000";
                            if ((horas_decenas = "10") and (horas = "0011"))  then
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
        elsif ((inicio_alarma = '1') and (contador_base = 50000000)) then
            if ((segundos = "0000") and (segundos_decenas = "0000" ) and (minutos = "0000") and (minutos_decenas = "0000")  and (horas = "0000") and (horas_decenas = "0000")) then
                inicio_alarma <= '0';
            elsif ( segundos = "0000" ) then 
                segundos <= "1001";
                if (segundos_decenas = "0000" ) then
                    segundos_decenas <= "0101";
                    if (minutos = "0000") then
                        minutos <= "1001";
                        if (minutos_decenas = "0000" ) then
                            minutos_decenas <= "0101";
                            if ((horas = "0000") and (horas_decenas /= "0000")) then
                                horas_decenas <= horas_decenas - 1;
                            else
                                horas <= horas - 1;
                            end if;
                        else
                            minutos_decenas <= minutos_decenas - 1;
                        end if;
                    else
                        minutos <= minutos - 1;
                    end  if;
                else
                    segundos_decenas <= segundos_decenas - 1;
                end if;
            else 
                segundos <= segundos - 1;
            end if;
        else
        end if;
    end if;
end process;


process(segundos,segundos_decenas,minutos, minutos_decenas, horas, horas_decenas)
begin

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

end process;

end Behavioral;