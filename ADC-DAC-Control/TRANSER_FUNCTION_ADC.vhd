--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/02/23) (10:34:30)
-- File: transfer_function_adc.vhd
--------------------------------------------------------------
-- Description:
--
-- This vhdl module does the transformation of the averaged
-- input value into mV to be able which is the mV read from
-- the ADC.
--------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity transfer_function_adc is

    port(
		CLK 		: in  std_logic;
		RST 		: in std_logic;
		i_DB 		: in  std_logic_vector (7 downto 0);
		o_ADC_value : out std_logic_vector (10 downto 0)		-- [0,1992] mV -> ADC range values
	);		

end entity transfer_function_adc;

architecture rtl of transfer_function_adc is
	
	constant	c_ADC_max_transfer_value	: integer range 2000 downto 0 												:= 2000;
	constant 	c_i_DB_max					: integer range 255 downto 0												:= 255;
	
	type 		t_r_o_ADC_value is array (0 to 4) of integer range c_ADC_max_transfer_value * c_i_DB_max downto 0;
	signal 		r_o_ADC_value 				: t_r_o_ADC_value															:= (others => 0);

begin

	p_Transfer_Function:
		process (CLK, RST, r_o_ADC_value)
		begin
				
			if (RST = '0') then
				
				r_o_ADC_value <= (others => 0);
				
			elsif ( rising_edge(CLK) ) then
				
				r_o_ADC_value(0) <= to_integer( shift_left(resize(unsigned(i_DB), 19), 10) + shift_left(resize(unsigned(i_DB), 19), 9) );
				r_o_ADC_value(1) <= to_integer( r_o_ADC_value(0) + shift_left(resize(unsigned(i_DB), 19), 8) );
				r_o_ADC_value(2) <= to_integer( r_o_ADC_value(1) + shift_left(resize(unsigned(i_DB), 19), 7) );
				r_o_ADC_value(3) <= to_integer( r_o_ADC_value(2) + shift_left(resize(unsigned(i_DB), 19), 6) );
				r_o_ADC_value(4) <= to_integer( r_o_ADC_value(3) + shift_left(resize(unsigned(i_DB), 19), 4) )/256;
				
			end if;
					
		end process p_Transfer_Function;
		
	-- -- -- -- -- -- -- -- -- -- -- --
	-- ADC value send [mV]
	-- -- -- -- -- -- -- -- -- -- -- --
	o_ADC_value <= std_logic_vector(to_unsigned( r_o_ADC_value(4) , 11));
	
end architecture rtl;

