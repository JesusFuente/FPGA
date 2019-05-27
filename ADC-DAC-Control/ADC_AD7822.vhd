--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/02/13) (18:34:03)
-- File: adc_ad7822.vhd
--------------------------------------------------------------
-- Description:
--
-- This vhdl module contains all the blocks necessaries to
-- make the ADC work: Conversion start, Average block, etc...
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adc_ad7822 is

	generic(
		g_30us_PWR				: integer := 9000;
		g_70ns_CONVST_END		: integer := 21;
		g_120ns_CONVST			: integer := 36;
		g_40ns_EOC				: integer := 2
	);	
		
	port(	
		CLK						: in std_logic;
		RST						: in std_logic;
			
		i_EOC					: in std_logic;
		i_DB					: in std_logic_vector(7 downto 0);
		i_calibrate				: in std_logic;
			
		o_read 					: out  std_logic;
		o_CONVST				: out std_logic;
		o_calibration_LED 		: out std_logic;
		o_average_done 			: out  std_logic;
		o_ADC_value				: out std_logic_vector(10 downto 0)
	);

end entity adc_ad7822;

architecture structural of adc_ad7822 is
	
	signal w_o_DB_read_adc		: std_logic_vector(7 downto 0);
	signal w_o_read				: std_logic;
	signal w_o_DB_average_adc 	: std_logic_vector(7 downto 0);

begin

	inst_clk_convst:
		entity work.clk_convst(rtl)
		generic map(
			g_30us_PWR 			=> g_30us_PWR,
			g_70ns_CONVST_END 	=> g_70ns_CONVST_END,
			g_120ns_CONVST 		=> g_120ns_CONVST
		)
		port map(CLK => CLK, RST => RST, i_EOC => i_EOC, o_CONVST => o_CONVST);

	inst_ADC_lecture:
		entity work.read_adc(rtl)
		generic map(
			g_40ns_EOC 	=> g_40ns_EOC
		)
		port map(
			CLK 				=> CLK,
			RST 				=> RST,
			i_EOC 				=> i_EOC,
			i_DB 				=> i_DB,
			o_DB 				=> w_o_DB_read_adc,
			o_read 				=> w_o_read
		);

	inst_ADC_average:
		entity work.average_adc(rtl)
		port map(
			CLK 				=> CLK,
			RST 				=> RST,
			i_read 				=> w_o_read,
			i_DB 				=> w_o_DB_read_adc,
			i_calibrate 		=> i_calibrate,
			o_DB				=> w_o_DB_average_adc,
			o_calibration_LED 	=> o_calibration_LED,
			o_average_done 		=> o_average_done
		);

	inst_Transfer_Function:
		entity work.transfer_function_adc(rtl)
		port map(
			CLK 				=> CLK,
			RST 				=> RST,
			i_DB 				=> w_o_DB_average_adc,
			o_ADC_value 		=> o_ADC_value
		);
	
	w_signals:
		o_read <= w_o_read;

end architecture structural;