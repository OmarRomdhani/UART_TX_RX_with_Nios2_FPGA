
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity uart_tb is
end uart_tb;
 
architecture behave of uart_tb is
 
  component uart is
    generic (
          Clk_Bit : integer := 115   -- Needs to be set correctly
      );
    port (
    Clk         : in  std_logic;
    i_TX   : in  std_logic_vector(7 downto 0);
    o_RX   : out  std_logic_vector(7 downto 0);
    interr_RX   : out std_logic;
    start_TX    : in std_logic;
    busy_TX     : out std_logic;
 -----------------------
    o_TX_Serial : out std_logic;
    i_RX_Serial : in std_logic
    );
  end component uart;
 
  
  -- Test Bench uses a 10 MHz Clock
  -- Want to interface to 115200 baud UART
  -- 10000000 / 115200 = 87 Clocks Per Bit.
  constant c_CLKS_PER_BIT : integer := 87;
 
  constant c_BIT_PERIOD : time := 8680 ns;
   
  signal r_CLOCK     : std_logic                    := '0';
  signal r_TX_start     : std_logic                    := '0';
  signal r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
  signal w_TX_SERIAL : std_logic;
  signal w_TX_busy   : std_logic;
  signal w_RX_inter     : std_logic;
  signal w_RX_BYTE   : std_logic_vector(7 downto 0);
  signal r_RX_SERIAL : std_logic := '0';
 
   
  -- Low-level byte-write
  procedure UART_WRITE_BYTE (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
  begin
 
    -- Send Start Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
 
    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= i_data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii
 
    -- Send Stop Bit
    o_serial <= '0';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;
 
   
begin
 
  -- Instantiate UART transmitter
  UART_INST : uart
    generic map (
          Clk_Bit => c_CLKS_PER_BIT
      )
    port map (
		clk      	 => r_CLOCK,
		i_tx  		 => r_TX_BYTE,
		O_Rx 		 => w_RX_BYTE,
		interr_RX    => w_RX_inter,
		start_TX   	 =>  r_TX_start,
		busy_TX 	 => w_TX_busy ,
 -----------------------
    o_TX_Serial 	 => w_TX_SERIAL,
    i_RX_Serial  	 => r_RX_SERIAL
      );
 
 
  r_CLOCK <= not r_CLOCK after 50 ns;
   
  process is
  begin
 
    -- Tell the UART to send a command.
    wait until rising_edge(r_CLOCK);
    wait until rising_edge(r_CLOCK);
    r_TX_start   <= '1';
    r_TX_BYTE <= X"AB";
    wait until rising_edge(r_CLOCK);
    r_TX_start   <= '0';
    wait until w_TX_busy = '0';
       report "Test Passed - Sent Correctly" severity note;
     
    -- Send a command to the UART
    wait until rising_edge(r_CLOCK);
    UART_WRITE_BYTE(X"3F", r_RX_SERIAL);
    wait until rising_edge(r_CLOCK);
 
    -- Check that the correct command was received
    if w_RX_BYTE = X"3F" then
      report "Test Passed - Correct Byte Received" severity note;
    else
      report "Test Failed - Incorrect Byte Received" severity note;
    end if;
 
    assert false report "Tests Complete" severity failure;
     
  end process;
   
end behave;