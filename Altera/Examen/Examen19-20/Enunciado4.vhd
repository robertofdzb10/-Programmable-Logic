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
signal bt: std_logic;
signal unidades_piso: std_logic_vector (3 downto 0);
signal decenas_piso: std_logic_vector (3 downto 0);
signal decenas_null: std_logic;

signal estado: std_logic_vector (2 downto 0);
signal flt: integer range 0 to 500000000;
signal flt_2: integer range 0 to 500000;
signal sal: std_logic;



begin

inicio<=v_bt(0);
bt<=v_bt(1);

process(inicio, g_clock_50, bt)
begin
    if (inicio = '0') then
        estado <="000";
        sal <= '0';
        flt <= 0;
        flt_2 <= 0;
    elsif (rising_edge (g_clock_50)) then
        case estado is
            when "000" =>
                flt <= 0;
                sal <= '0';
                flt_2 <= 0;
                if (bt = '1') then
                    estado <= "000";
                elsif (bt = '0') then
                    estado <= "001";
                end if;
            when "001" =>
                flt <= flt + 1;
                sal <= '0';
                flt_2 <= 0;
                if (bt = '1') then
                    estado <= "000";
                elsif ( (bt = '0')  and (flt < 50000) ) then
                    estado <= "001";
                elsif ( (bt = '0')  and (flt = 50000) ) then
                    estado <= "010";      
                end if;
            when "010" =>
                flt <= flt + 1;
                sal <= '0';
                flt_2 <= 0;
                if (bt = '0') then
                    estado <= "010";
                elsif (bt = '1') then
                    estado <= "110"; 
                end if;
            when "110" =>
                flt <= flt + 1;
                sal <= '0';
                flt_2 <= 0;
                if (bt = '1') then
                    estado <= "110";
                elsif (bt = '0') then
                    estado <= "100"; 
                end if;
            when "100" =>
                flt <= flt + 1;
                sal <= '0';
                flt_2 <= flt_2 + 1;
                if ( bt = '1') then
                    estado <= "000";
                elsif ( (bt = '0')  and (flt_2 < 50000) ) then
                    estado <= "100";
                elsif ( (bt = '0')  and (flt_2 = 50000) ) then
                    estado <= "101";      
                end if;
            when "101" =>
                flt <= flt + 1;
                sal <= '0';
                flt_2 <= 0;
                if (bt = '0') then
                    estado <= "101";
                elsif ((bt = '1') and (flt <= 50000000)) then
                    estado <= "011"; 
                elsif ((bt = '1') and (flt > 50000000)) then
                    estado <= "000"; 
                end if;
            when "011" =>
                flt <= 0;
                sal <= '1';
                flt_2 <= 0;
                estado <= "000";
            when others =>
                flt <= 0;
                sal <= '0';
                flt_2 <= 0;
                estado <= "000";
        end case;
    end if;
end process;

process(inicio, bt, g_clock_50)
begin
    if (inicio = '0') then
        unidades_piso <= "0000";
        decenas_piso <= "0000";
    elsif (rising_edge (g_clock_50)) then
        if (sal = '1') then
            if ((decenas_piso = "0001") and (unidades_piso = "0010")) then
                unidades_piso <= unidades_piso + 2;
            elsif (unidades_piso = "1001") then
                unidades_piso <= "0000";
                if (decenas_piso = "0010") then
                    decenas_piso <= decenas_piso;
                else
                    decenas_piso <= decenas_piso + 1;
                end if;
            else
                if (decenas_piso /= "0010") then
                    unidades_piso <= unidades_piso + 1;
                else
                end if;
            end if;
        else
        end if;
    end if;
end process;


process(g_clock_50, decenas_piso)
begin
    if (rising_edge(g_clock_50)) then
        if (decenas_piso = "0000") then
            decenas_null <= '1';
        else 
            decenas_null <= '0';
        end if;
    end if;
end process;


process(g_clock_50, unidades_piso, decenas_piso, decenas_null)
begin
    case unidades_piso is
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
        case decenas_piso is
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
    g_hex2<="1111111";
    g_hex3<="1111111";
    g_hex4<="1111111";
    g_hex5<="1111111";
end process;
 
end Behavioral;
