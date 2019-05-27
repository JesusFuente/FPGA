
--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/02/10) (21:43:22)
-- File: TOP_ADC_ACQUISITION.vhd
--------------------------------------------------------------
-- Description:
--
-- This top VHDL architecture contains the ADC module, PLL
-- module and all the modules required to make the firmware
-- for the ADC converter.
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_adc_acquisition is
	
	generic(
		-- -- -- -- -- -- -- -- -- -- -- --
		-- inst_ADC_7822 component variables
		-- -- -- -- -- -- -- -- -- -- -- --
		g_30us_CLK_300MHz				: integer 										:= 9000;
		g_70ns_CLK_300MHz				: integer 										:= 200;	-- 21
		g_120ns_CLK_300MHz				: integer 										:= 36;
		g_40ns_EOC_CLK_300MHz			: integer 										:= 1;
		g_clk_fast_slow_stretch			: integer										:= 12
	);	
		
	port(	
		OSC_50_B3						: in std_logic;
		CPU_RESET_n						: in std_logic;
					
		GPIO0_D10						: in std_logic;
		GPIO0_D_i_DB					: in std_logic_vector(7 downto 0);
		BUTTON0							: in std_logic;
				
		GPIO0_D27						: out std_logic;
		GPIO0_D28						: out std_logic;
		LED0							: out std_logic;
		GPIO0_D29						: out std_logic;
		GPIO0_D_DISPLAY					: out std_logic_vector(10 downto 0)
	);
	
end entity top_adc_acquisition;

architecture structural of top_adc_acquisition is

	-- -- -- -- -- -- -- -- -- -- -- --
	-- General Clock Signal
	-- -- -- -- -- -- -- -- -- -- -- --
	signal 		w_CLK					: std_logic;
	signal 		w_c0_from_PLL_1			: std_logic;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Reset signals
	-- -- -- -- -- -- -- -- -- -- -- --
	signal 		w_RST					: std_logic;
	signal 		w_RST_n					: std_logic;
	constant 	c_RST_N_SYNC			: integer range 2 downto 0 						:= 2;
		
	constant 	c_RST_PLL_1				: integer range 0 downto 0	 					:= 0;
	constant 	c_RST_SYNC				: integer range 1 downto 0	 					:= 1;
	constant 	c_RST_ADC				: integer range 2 downto 0	 					:= 2;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- End of Conversion signals
	-- -- -- -- -- -- -- -- -- -- -- --
	signal		w_i_EOC					: std_logic;
	signal 		r_EOC					: std_logic_vector (c_RST_N_SYNC-1 downto 0);
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- inst_PLL_1 Component -> 300 MHz output
	-- -- -- -- -- -- -- -- -- -- -- --
	component PLL_1 is
		port(
			areset						: in std_logic;
			inclk0						: in std_logic;
			c0							: out std_logic
		);
	end component PLL_1;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- inst_ADC_7822 component variables
	-- -- -- -- -- -- -- -- -- -- -- --
	signal		w_o_CONVST 				: std_logic;
	signal		w_i_DB					: std_logic_vector(7 downto 0);
	signal		w_o_read				: std_logic;
	signal		w_i_calibrate			: std_logic;
	signal 		w_o_calibration_LED		: std_logic;
	signal 		w_o_average_done		: std_logic;
	signal 		w_o_ADC_value			: std_logic_vector(10 downto 0);
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Sync_Fast_to_Slow component variables
	-- -- -- -- -- -- -- -- -- -- -- --
	signal 		w_o_Sync_Fast_to_Slow	: std_logic_vector(10 downto 0);
	
begin

	inst_PLL_1:
		PLL_1
		port map(
			areset 				=> w_RST_n,
			inclk0 				=> w_CLK,
			c0 					=> w_c0_from_PLL_1
		);
		
	inst_ADC_7822:
		entity work.adc_ad7822(structural)
		generic map(
			g_30us_PWR 			=> g_30us_CLK_300MHz,
			g_70ns_CONVST_END 	=> g_70ns_CLK_300MHz,
			g_120ns_CONVST		=> g_120ns_CLK_300MHz,
			g_40ns_EOC 			=> g_40ns_EOC_CLK_300MHz
		)
		port map(
			CLK 				=> w_c0_from_PLL_1,
			RST 				=> w_RST,
			i_EOC 				=> r_EOC(c_RST_N_SYNC-1),
			i_DB 				=> w_i_DB,
			i_calibrate 		=> w_i_calibrate,
			o_read 				=> w_o_read,
			o_CONVST 			=> w_o_CONVST,
			o_calibration_LED 	=> w_o_calibration_LED,
			o_average_done		=> w_o_average_done,
			o_ADC_value			=> w_o_ADC_value
		);
		
	inst_Sync_Fast_to_Slow:
		entity work.Sync_Fast_to_Slow(rtl)
		generic map(
			g_i_length => w_o_ADC_value'length,
			g_clk_fast_slow_stretch => g_clk_fast_slow_stretch
		)
		port map(
			i_RST => w_RST,	
			i_CLK => w_c0_from_PLL_1,
		    i_DB => w_o_ADC_value,	
		    o_DB => w_o_Sync_Fast_to_Slow
		);
		
	p_SYNC:
		process (w_RST, w_c0_from_PLL_1, w_i_EOC)	
		begin
			
			if (w_RST = '0') then
				
				r_EOC <= (others => '1');

			elsif (rising_edge(w_c0_from_PLL_1)) then
			
				r_EOC(0) <= w_i_EOC;
			
				l_RST_SYNC:
					for i in c_RST_N_SYNC-1 downto 1 loop
					
						r_EOC(i downto 1) <= r_EOC((i-1) downto 0);
						
					end loop l_RST_SYNC;
				
			end if;
		
		end process p_SYNC;
		
	w_signals:
		w_CLK 					<= OSC_50_B3;
		w_RST 					<= CPU_RESET_n;
		w_RST_n					<= not CPU_RESET_n;
		w_i_EOC 				<= GPIO0_D10;
		GPIO0_D27 				<= w_o_CONVST;
		w_i_DB					<= GPIO0_D_i_DB;
		GPIO0_D28   			<= w_o_read;
		w_i_calibrate 			<= BUTTON0;
		LED0					<= w_o_calibration_LED;
		GPIO0_D29				<= w_o_average_done;
		GPIO0_D_DISPLAY			<= w_o_Sync_Fast_to_Slow;
		
end architecture structural;