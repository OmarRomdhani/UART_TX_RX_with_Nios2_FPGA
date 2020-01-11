library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

 entity UART is
  generic (
    Clk_Bit : integer := 10     -- Needs to be set correctly
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
end UART;
architecture RTL of UART is 
type state is (idle,starting, busy, done);

signal Rx_SM : state := idle ;
signal Tx_SM : state := idle ;
signal clk_counter_Tx : integer := 0;
signal clk_counter_Rx : integer := 0;
signal bit_index_TX :  integer range 0 to 7 := 0;  -- 8 Bits Total
signal bit_index_RX :  integer range 0 to 7 := 0;  -- 8 Bits Total
signal Tx_Data : std_logic_vector(7 downto 0);
signal Rx_Data : std_logic_vector(7 downto 0);

begin 
 Tx_Process: process(clk) 
 begin
	if clk ='1' then	
		case Tx_SM is 
		when idle => 
		busy_TX <= '0' ; -- NOT BUSY 
		o_TX_Serial <= '0'; --- Default value / not sending 
		clk_counter_Tx <= 0;
		bit_index_TX <= 0;
		
		if start_TX = '1' then
		Tx_SM <= starting ;
		Tx_Data <= i_TX  ;
		else 
		Tx_SM <= idle ;
		end if;
		
		when starting => 
		o_TX_Serial <= '1' ;
		busy_TX <= '1';
		if clk_counter_Tx < clk_bit -1 then
			clk_counter_Tx <= clk_counter_Tx + 1;
			Tx_SM <= starting ;
		else 
			tx_sm <= busy ;
			clk_counter_Tx <=0;
		end if;
		
		when busy =>
			if clk_counter_Tx < clk_bit - 1 then 
				clk_counter_Tx <= clk_counter_Tx +1;
				o_TX_Serial <= Tx_Data(bit_index_tx);
			else 
				clk_counter_Tx <=0 ;
				if bit_index_TX <7 then 
					bit_index_TX <= bit_index_TX +1;
				else 
					bit_index_TX <=0;
					tx_sm <= done;
				end if;
			end if;
			
		when done =>
			o_TX_Serial <= '0';
			if clk_counter_Tx <clk_bit -1 then
				clk_counter_Tx <= clk_counter_Tx +1;
				tx_sm <= done;
			else 
				tx_sm <= idle;
			end if;
		end case;	
	end if ;
 end process;


Rx_Process: process(clk) 
 begin
	if clk ='1' then	
		case Rx_SM is 
		when idle => 
		clk_counter_Rx <= 0;
		bit_index_RX <= 0;
		if i_RX_Serial = '1' then
			rx_sm <= starting;
		else 
			rx_sm <= idle;
		end if ;
		
		when starting =>
		if clk_counter_Rx =(clk_bit-1)/2 then 
			if i_RX_Serial = '1' then
				rx_sm <= busy ;
				clk_counter_Rx <= 0;
			else 
				rx_sm <= idle;
			end if;
		else 
			if i_RX_Serial = '0' then
				rx_sm <= idle ;
			else
				clk_counter_Rx <= clk_counter_Rx +1 ;
				rx_sm <= starting;	
			end if;
		end if;
		
		when busy =>
		if clk_counter_Rx < clk_bit -1 then 
			clk_counter_Rx <= clk_counter_Rx +1;
			rx_sm <= busy;
		else
			o_RX(bit_index_RX) <= i_RX_Serial;
			clk_counter_Rx <= 0;
			if bit_index_RX < 7 then 
				bit_index_RX <= bit_index_RX +1;
				rx_sm <= busy;
			else 
				bit_index_RX <=0;
				interr_RX<='1';
				rx_sm <= done;
			end if;
		end if ;
		when done => 
		interr_RX <='0';
		if clk_counter_Rx < clk_bit -1 then 
			clk_counter_Rx <= clk_counter_Rx +1;
			rx_sm <= done;
		else 
			rx_sm<= idle;
		end if;
		end case ;
	end if;
 end process;

end RTL;