
--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: 2019/02/09
-- File: tb_TOP_ADC_ACQUISITION.vhd
--------------------------------------------------------------
-- Description:
-- 
-- This is the TestBench for the Top architecture. To check if
-- the ADC VHDL interacts correctly with the ADCs.
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_top_adc_acquisition is
end entity tb_top_adc_acquisition;

architecture behavioral of tb_top_adc_acquisition is
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Variables for Reset signal
	-- -- -- -- -- -- -- -- -- -- -- --
	constant 	c_40ns_RST				: time 									:= 40 ns;
	constant 	c_70us_RST				: time 									:= 70 us;
	constant 	c_10us_RST				: time 									:= 10 us;
	signal 		r_RST					: std_logic 							:= '1';
							
	-- -- -- -- -- -- -- -- -- -- -- --						
	-- Variables for general Clock signal						
	-- -- -- -- -- -- -- -- -- -- -- --						
	constant 	c_20ns_CLK				: time 									:= 20 ns;
	signal 		r_20ns_CLK				: std_logic 							:= '0';
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Variables for End of Conversion signal
	-- -- -- -- -- -- -- -- -- -- -- --
	constant 	c_D_EOC					: integer 								:= 6;
	constant 	c_370ns_EOC				: time 									:= 370 ns;
	constant 	c_Ton_EOC				: time 									:= (c_D_EOC * c_370ns_EOC)/100;
	constant 	c_Toff_EOC				: time 									:= c_370ns_EOC - (c_D_EOC * c_370ns_EOC)/100;
	signal 		r_370ns_EOC				: std_logic								:= '0';
							
	-- -- -- -- -- -- -- -- -- -- -- --						
	-- Variables for inst_TOP_ADC_ACQUISITION component						
	-- -- -- -- -- -- -- -- -- -- -- --						
	constant 	g_30us_CLK_300MHz		: integer 								:= 9000;
	constant 	g_70ns_CLK_300MHz		: integer 								:= 21;
	constant 	g_120ns_CLK_300MHz		: integer 								:= 36;
	constant 	g_40ns_EOC_CLK_300MHz	: integer 								:= 1;
	constant 	g_clk_fast_slow_stretch	: integer 								:= 12;
	
	signal 		w_o_CONVST 				: std_logic;	
	signal 		w_RST_STATE 			: std_logic_vector(2 downto 0);	
	signal 		w_ADC_STATE 			: std_logic_vector(3 downto 0);
	signal 		w_o_read				: std_logic;
	signal 		w_o_calibration_LED		: std_logic;
	signal		w_o_average_done		: std_logic;
	signal		w_o_ADC_value			: std_logic_vector(10 downto 0);
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Input number generator signals
	-- -- -- -- -- -- -- -- -- -- -- --
	constant 	c_400ns_GPIO0_D_i_DB	: time 									:= 400 ns;
	constant	c_ADC_max_N				: integer 								:= 1992;
	signal 		r_GPIO0_D_i_DB			: integer range c_ADC_max_N downto 0 	:= 0;
	signal 		w_GPIO0_D_i_DB			: std_logic_vector(7 downto 0);
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Calibration & Average signals
	-- -- -- -- -- -- -- -- -- -- -- --
	constant 	c_1us_CALIBRATION		: time 									:= 1 us;
	signal 		r_BUTTON0				: std_logic								:= '1';

begin
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Components instantiations
	-- -- -- -- -- -- -- -- -- -- -- --
	inst_TOP_ADC_ACQUISITION:
		entity work.top_adc_acquisition(structural)
		generic map(
			g_30us_CLK_300MHz 		=> g_30us_CLK_300MHz,
			g_70ns_CLK_300MHz 		=> g_70ns_CLK_300MHz,
			g_120ns_CLK_300MHz 		=> g_120ns_CLK_300MHz,
			g_40ns_EOC_CLK_300MHz 	=> g_40ns_EOC_CLK_300MHz,
			g_clk_fast_slow_stretch	=> g_clk_fast_slow_stretch
		)
		port map(
			OSC_50_B3 				=> r_20ns_CLK,
			CPU_RESET_n 			=> r_RST,
			GPIO0_D10 				=> r_370ns_EOC,
			GPIO0_D_i_DB			=> w_GPIO0_D_i_DB,
			BUTTON0					=> r_BUTTON0,
			
			GPIO0_D27 				=> w_o_CONVST,
			GPIO0_D28 				=> w_o_read,
			LED0					=> w_o_calibration_LED,
			GPIO0_D29				=> w_o_average_done,
			GPIO0_D_DISPLAY 		=> w_o_ADC_value
		);	
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Clocks Generation
	-- -- -- -- -- -- -- -- -- -- -- --
	r_20ns_CLK <= not r_20ns_CLK after c_20ns_CLK/2;
	
	p_i_EOC:
		process is
		begin
			
			r_370ns_EOC <= '0';
			wait for c_Ton_EOC;
			r_370ns_EOC <= '1';
			wait for c_Toff_EOC;
		
		end process p_i_EOC;

	-- -- -- -- -- -- -- -- -- -- -- --
	-- Input numbers generator
	-- -- -- -- -- -- -- -- -- -- -- --
	p_Generate_Input_Number:
		process
		begin

			wait for c_400ns_GPIO0_D_i_DB;
			
			if (r_GPIO0_D_i_DB >= c_ADC_max_N) then
				
				r_GPIO0_D_i_DB <= 0;
				
			else
			
				r_GPIO0_D_i_DB <= r_GPIO0_D_i_DB + 1;
			
			end if;
	
		end process p_Generate_Input_Number;
		
		w_GPIO0_D_i_DB <= std_logic_vector(to_unsigned(r_GPIO0_D_i_DB, w_GPIO0_D_i_DB'length));
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Calibration signal generation
	-- -- -- -- -- -- -- -- -- -- -- --
	p_CALIBRATION:
		process
		begin
		
			r_BUTTON0 <= '1';
			wait for c_1us_CALIBRATION;
			r_BUTTON0 <= '0';
			wait for c_1us_CALIBRATION;
		
		end process p_CALIBRATION;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- TestBench Body
	-- -- -- -- -- -- -- -- -- -- -- --
	p_TEST_BENCH_BODY:
		process is
		begin
			
			report "Starting TestBench ...";
			r_RST <= '0';
			wait for c_40ns_RST;
			r_RST <= '1';
			wait for c_70us_RST;
			r_RST <= '0';
			wait for c_10us_RST;
			r_RST <= '1';
			wait for c_70us_RST;
			assert false report "Test Completed!" severity failure;
		
		end process p_TEST_BENCH_BODY;

end behavioral;