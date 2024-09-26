----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.09.2024 08:47:58
-- Design Name: 
-- Module Name: tx_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trx_tb is
--  Port ( );
end trx_tb;

architecture Behavioral of trx_tb is
component trx is
    port(
        Reset, Start, Clk : in std_logic;
        Data  : in std_logic_vector(7 downto 0);
        Tx, Eot : out std_logic
    );
end component;

signal Reset, Start, Clk, Tx, Eot : std_logic;
signal Data : std_logic_vector(7 downto 0);

constant ClkPeriod: time := 10 ns;

constant Datain: std_logic_vector(7 downto 0) := "01011011";
begin

Reset <= '1', '0' after 2*ClkPeriod, '1' after 17*ClkPeriod;
Data <= Datain;
process
begin
    Clk <= '0';
    wait for ClkPeriod/2;
    Clk <= '1';
    wait for ClkPeriod/2;
end process;

process
begin
    Start <= '0';
    wait until Reset = '0';
    wait until Reset = '1';
    wait for 4*ClkPeriod;
    Start <= '1';
    wait for ClkPeriod;
    Start <= '0';
 
end process;

Transmisor : trx
    port map(
        Reset => reset,
        Clk => clk,
        Start => start,
        Data => data,
        Tx => tx,
        Eot => eot
    );

end Behavioral;
