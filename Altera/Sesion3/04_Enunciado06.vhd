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

signal estado: std_logic_vector (2 downto 0);
signal cont_filtro: integer range 0 to 100000000;
signal puls_sal: std_logic;
signal contador_unidades_seg: std_logic_vector (3 downto 0);

signal horas_decenas_alarma: std_logic_vector (3 downto 0);
signal horas_unidades_alarma: std_logic_vector (3 downto 0);
signal minutos_decenas_alarma: std_logic_vector (3 downto 0);
signal minutos_unidades_alarma: std_logic_vector (3 downto 0);
signal dato: std_logic_vector (3 downto 0);

signal enable_seg_aux: std_logic_vector (3 downto 0);
signal contador_base_enable: integer range 0 to 100000;

begin

process(clk, inicio)
begin
if inicio='1' then	
	estado<="000";
	cont_filtro<=0;
elsif rising_edge(clk) then
	case estado is
    when "000" =>   cont_filtro<=0;
                    if pulsador='1' then
                        estado<="001";
                    end if;                        
    when "001" =>   cont_filtro<=cont_filtro+1;
                    if pulsador='0' then
                        estado<="000";
                    elsif pulsador='1' and cont_filtro=100000 then
                        estado<="010";
                    end if;                        
    when "010" =>   cont_filtro<=cont_filtro+1;
                    if pulsador='0' then
                        estado<="011";
                    elsif cont_filtro=100000000 then 
                        estado<="100";   
                    end if;                        
    when "011" =>   cont_filtro<=0;
                    estado<="000";
    when "100" =>   cont_filtro<=0;
                    if pulsador='1' then
                        estado<="101";
                    else
                        estado<="011";
                    end if;        
    when "101" =>   cont_filtro<=cont_filtro+1;
                    if pulsador='0' then
                        estado<="011";
                    elsif cont_filtro=25000000 then
                        estado<="100";
                    end if;    
    when others =>   cont_filtro<=0;
                    estado<="000";
	end case;
end if;
end process;

process(estado)
begin
case estado is
	when "000" => puls_sal<='0';
	when "001" => puls_sal<='0';
	when "010" => puls_sal<='0';
	when "011" => puls_sal<='1';
	when "100" => puls_sal<='1';
	when "101" => puls_sal<='0';
	when others => puls_sal<='0';
end case;
end process;

process(inicio, clk)
begin
if inicio='1' then
    minutos_unidades_alarma<="0000";
    minutos_decenas_alarma<="0000";
    horas_unidades_alarma<="0000";
    horas_decenas_alarma<="0000";
elsif rising_edge(clk) then
    if puls_sal='1' then
    if minutos_unidades_alarma=9 then
        minutos_unidades_alarma<="0000";
        if minutos_decenas_alarma=5 then
            minutos_decenas_alarma<="0000";
            if horas_unidades_alarma=9 or (horas_unidades_alarma=3 and horas_decenas_alarma=2) then
                horas_unidades_alarma<="0000";
                if horas_unidades_alarma=3 and horas_decenas_alarma=2 then
                    horas_decenas_alarma<="0000";
                else
                    horas_decenas_alarma<=horas_decenas_alarma+1;
                end if;    
            else
                horas_unidades_alarma<=horas_unidades_alarma+1;
            end if;    
        else
            minutos_decenas_alarma<=minutos_decenas_alarma+1;
        end if;    
    else
        minutos_unidades_alarma<=minutos_unidades_alarma+1;
    end if;    
    end if;
end if;
end process;

process(clk, inicio)
begin
if inicio='1' then
	contador_base_enable<=0;
elsif rising_edge(clk) then	
	if contador_base_enable=100000 then
		contador_base_enable<=0;
	else
		contador_base_enable<=contador_base_enable+1;
	end if;
end if;
end process;

process(clk, inicio)
begin
if inicio='1' then
	enable_seg_aux<="0111";
elsif rising_edge(clk) then
	if contador_base_enable=100000 then
		enable_seg_aux<=enable_seg_aux(2 downto 0)&enable_seg_aux(3);
	end if;
end if;
end process;

process(enable_seg_aux, horas_decenas_alarma, horas_unidades_alarma, minutos_decenas_alarma, minutos_unidades_alarma)
begin
case enable_seg_aux is
	when "0111" => dato<=horas_decenas_alarma;
	when "1011" => dato<=horas_unidades_alarma;
	when "1101" => dato<=minutos_decenas_alarma;
	when "1110" => dato<=minutos_unidades_alarma;
	when others => dato<="1111";
end case;
end process;

process(dato)
begin
case dato is
when "0000" => seven_seg<="0000001";
when "0001" => seven_seg<="1001111";
when "0010" => seven_seg<="0010010";
when "0011" => seven_seg<="0000110";
when "0100" => seven_seg<="1001100";
when "0101" => seven_seg<="0100100";
when "0110" => seven_seg<="1100000";
when "0111" => seven_seg<="0001111";
when "1000" => seven_seg<="0000000";
when "1001" => seven_seg<="0001100";
when others => seven_seg<="1111111";
end case;
end process;

enable_seg<=enable_seg_aux;


end Behavioral;
