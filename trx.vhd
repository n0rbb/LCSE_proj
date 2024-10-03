----------------------------------------------------------------------------------
-- Engineer: Mario de Miguel
-- 
-- Create Date: 20.09.2024 11:42:18
-- Design Name: 
-- Module Name: tx - Behavioral
-- Project Name: LCSE
-- Target Devices: 
-- Tool Versions: 
-- Description: Transmisor protocolo RS232
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trx is
    port(
        reset, start, clk : in std_logic;
        data : in std_logic_vector(7 downto 0);
        tx, eot : out std_logic
    );
end trx;


architecture Behavioral of trx is
    type estados is (idle, startBit, sendData, stopBit);
    signal current_state, next_state : estados;
    signal step : std_logic := '0'; --Flag de llamada al secuencial.
    signal data_count : natural := 0;
    signal Pulse_width : unsigned(7 downto 0);
    constant PulseEndOfCount : unsigned(7 downto 0) := to_unsigned(173, 8); --173 en 8 bits, + un ciclo de registro.
    
begin
    combinacional : process(step) --Lógica de transiciones y de salidas. NO SECUENCIAL. Esto se va a ejecutar cada vez que current_state cambie.
    begin
            case current_state is
                when idle =>
                    eot <= '1'; --EOT activo en idle.
                    tx <= '1'; -- Pasamos un 1 porque no hay transmisión.
                    if (start = '1') then
                        next_state <= startBit;
                    else
                        next_state <= idle;
                    end if;
 
               when startBit =>
                    eot <= '0'; -- Bajamos EOT.
                    tx <= '0'; -- El primer bit es siempre un 0;
                    next_state <= sendData;
                    
                when sendData =>
                    --eot <= '0' -- En teoría no debería cambiar EOT. 
                    tx <= data(data_count - 2);
                    if (data_count = 9) then --Téngase en cuenta que aquí ponemos el flag a stopBit, pero queda un ciclo de ejecución antes de asignar al current state porque step activa otra vez esto.
                        next_state <= stopBit;  
                    else
                        next_state <= sendData;              
                    end if;
                   
                when stopBit =>
                    --data_count <= 1; 
                    tx <= '1'; -- El bit de terminar es un 1
                    eot <= '0';
                    next_state <= idle;
            end case;
            
    end process combinacional;
    
    secuencial : process(clk, reset) --El proceso secuencial incrementa los contadores que tenga que incrementar y llama a combinacional.
    begin
        if (reset = '0') then --Reset asíncrono (se puede resetear en estado de reloj). 
            current_state <= idle;
            pulse_width <= "00000000";
            data_count <= 1;
        else 
            if CLK'event and CLK = '1' then
                   
              if (start = '1') then
                  step <= not step; 
              end if;
              
              if (current_state /= idle and next_state /= idle) then --Los estados no idle deben mantenerse durante el tiempo de bit (174 ciclos de reloj!)
                    pulse_width <= pulse_width + 1;
                    if (pulse_width = PulseEndOfCount) then
                    
                        if (current_state = sendData and data_count < 9) then --Esta tira se ejecuta en sendData
                            step <= not step;
                            data_count <= data_count + 1;
                            
                        else
                            step <= not step; --Esta tira es para StartBit y StopBit
                            data_count <= 1;
                            
                        end if;
                            
                       pulse_width <= (others => '0');   
                
                    end if;
                end if;
               
                current_state <= next_state; 
                  
            end if;
        end if;      
    end process secuencial;

end Behavioral;
