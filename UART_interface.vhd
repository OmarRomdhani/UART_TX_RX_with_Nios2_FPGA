LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY reg32_avalon_interface IS
PORT ( clock, resetn : IN STD_LOGIC;
read, write, chipselect : IN STD_LOGIC;
writedata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
byteenable : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
readdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
Q_export : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
END reg32_avalon_interface;
ARCHITECTURE Structure OF reg32_avalon_interface IS

SIGNAL in_TX,out_RX : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal in_start_Tx ,out_interr_RX ,out_busy_TX,out_TX_Serial,in_RX_Serial: std_logic;
COMPONENT uart1
port (
    Clk        : in  std_logic;
    i_TX   : in  std_logic_vector(7 downto 0);
    o_RX   : out  std_logic_vector(7 downto 0);
    interr_RX   : out std_logic;
    start_TX    : in std_logic;
    busy_TX     : out std_logic;
 -----------------------
    o_TX_Serial : out std_logic;
    i_RX_Serial : in std_logic
    );
END COMPONENT;
BEGIN
in_TX <= writedata(7 downto 0);
in_start_Tx <= writedata(8);
in_RX_Serial <= writedata(9);
uart_instance: uart1 PORT MAP (clock, in_TX ,out_RX ,out_interr_RX,in_start_Tx,out_busy_TX,out_TX_Serial,in_RX_Serial);
readdata(7 downto 0) <= out_RX(7 downto 0);
readdata(8) <= out_interr_RX;
readdata(9) <= out_TX_Serial;
readdata(10) <= out_busy_TX ;
Q_export(7 downto 0) <= out_RX(7 downto 0);
Q_export(8) <= out_interr_RX;
Q_export(9) <= out_TX_Serial;
Q_export(10) <= out_busy_TX ;
END Structure;