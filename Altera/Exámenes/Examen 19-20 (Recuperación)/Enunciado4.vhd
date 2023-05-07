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
signal boton: std_logic;
signal pulso: std_logic;
signal pulso_doble: std_logic;
signal cont: integer range 0 to 50000;
signal seg: integer range 0 to 500000000;
signal estado: std_logic_vector (2 downto 0);
signal unidades_piso: std_logic_vector (3 downto 0);
signal decenas_piso: std_logic_vector (3 downto 0);

begin

inicio<=v_bt(0);
boton<=v_bt(1);


process(g_clock_50,inicio, boton)
begin
    if (inicio = '0') then
        estado <= "000";
    elsif (rising_edge(g_clock_50)) then
        case estado is
            when "000"=>
                pulso <= '0';
                pulso_doble <= '0';
                cont <= 0;
                seg <= 0;
                if (boton = '0') then
                    estado <= "001";
                end if;
            when "001"=>
                pulso <= '0';
                pulso_doble <= '0';
                cont <= cont + 1;
                seg <= 0;
                if (boton = '0' and cont = 50000) then
                    estado <= "010";
                elsif (boton = '1') then
                    estado <= "000";
                end if;
            when "010"=>
                pulso <= '0';
                pulso_doble <= '0';
                cont <= 0;
                seg <= seg + 1;
                if (boton = '1' and seg > 50000000) then
                    estado <= "011";
                elsif (boton = '1' and seg < 50000000) then
                    estado <= "100";
                end if;
            when "011"=>
                pulso <= '1';
                pulso_doble <= '0';
                cont <= 0;
                seg <= 0;
                estado <= "000";
            when "100"=>
                pulso <= '0';
                pulso_doble <= '0';
                cont <= 0;
                seg <= seg + 1;
                if (boton = '0' and seg <= 50000000) then
                    estado <= "101";
                elsif (seg > 50000000) then
                    estado <= "011";
                end if;
            when "101"=>
                pulso <= '0';
                pulso_doble <= '0';
                cont <= 0;
                seg <= 0;
                if (boton = '1') then
                    estado <= "110";
                end if;
            when "110"=>
                pulso <= '0';
                pulso_doble <= '1';
                cont <= 0;
                seg <= 0;
                estado <= "000";
            when others=>
                pulso <= '0';
                pulso_doble <= '0';
                cont <= 0;
                seg <= 0;
                estado <= "000";
        end case;
    end if;
end process;


process(g_clock_50, boton, pulso, pulso_doble)
begin
    if (inicio = '0') then
        unidades_piso <= "0000";
        decenas_piso <= "0000";
    elsif (rising_edge(g_clock_50)) then
        if (pulso = '1') then
            if (unidades_piso = "1001") then
                unidades_piso <= "0000";
                if (decenas_piso = "0010") then
                    decenas_piso <= "0000";
                else 
                    decenas_piso <= decenas_piso + 1;
                end if;
            elsif (unidades_piso = "0010" and decenas_piso = "0001") then 
                unidades_piso <= unidades_piso + 2;
            elsif (decenas_piso /= "0010") then
                unidades_piso <= unidades_piso + 1;
            end if;
        elsif (pulso_doble = '1') then
            if (unidades_piso + 2 >= "1010") then
                if (unidades_piso = "1000" or decenas_piso = "0001") then 
                    unidades_piso <= "0000";
                elsif (decenas_piso /= "1001") then 
                    unidades_piso <= "0001";
                end if;
                if (decenas_piso = "0010") then
                    decenas_piso <= "0000";
                else 
                    decenas_piso <= decenas_piso + 1;
                end if;
            elsif (unidades_piso = "0001" and decenas_piso = "0001") then 
                unidades_piso <= unidades_piso + 3;
            elsif (decenas_piso /= "0010") then
                unidades_piso <= unidades_piso + 2;
            end if;
        end if;
    end if;
end process;

process(unidades_piso, decenas_piso)
begin
    g_hex2<="1111111";
    g_hex3<="1111111";    
    g_hex4<="1111111";
    g_hex5<="1111111";
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
        when others => g_hex0<="0110000";
    end case;
if (decenas_piso > "0000") then
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
        when others => g_hex1<="0110000";
    end case;
else 
    g_hex1<="1111111";
end if;
end process;
end Behavioral;
