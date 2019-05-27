
--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/02/10) (20:35:53)
-- File: CLK_CONVST.vhd
--------------------------------------------------------------
-- Description:
--
-- This VHDL code generates de Conversions start signal for ADC
-- and uses de End of Conversions signal from the ADC dues to
-- generate it.
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clk_convst is
	 
	generic(
		g_30us_PWR			: INTEGER := 9000;
		g_70ns_CONVST_END	: INTEGER := 21;
		g_120ns_CONVST		: INTEGER := 36
	);

    port(
		CLK					: in STD_LOGIC;
		RST					: in STD_LOGIC;
	
		i_EOC				: in STD_LOGIC;		-- T(max. LOW) = 370 ns => f(max. HIGH) = 2 702 702,703 Hz ; D = 6 % ; T_on = 22,2 ns ; (SIMULATION)
	
		o_CONVST			: out STD_LOGIC
	);

end clk_convst;

architecture rtl of clk_convst is

	-- -- -- -- -- -- -- -- -- -- -- --
	-- State Signals
	-- -- -- -- -- -- -- -- -- -- -- --
	type STATE_TYPE_1 is (INIT_STATE, PWR_ON_LOW, CHECK_EOC_1, PWR_ON_HIGH, CHECK_EOC_2, START_CONVERSION, END_CONVERSION_CHECK_1, END_CONVERSION_CHECK_2, CHECK_EOC_3, RE_CHECK_EOC_3, RESTART_TIME);
	signal Q1 : STATE_TYPE_1;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Conversion start signal
	-- -- -- -- -- -- -- -- -- -- -- --
	signal r_CONVST				: STD_LOGIC;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Counters for time delays for Power
	-- start delay, conversion time restrictions
	-- and end of conversion delay
	-- -- -- -- -- -- -- -- -- -- -- --
	signal r_30us_PWR			: INTEGER range g_30us_PWR downto 0 := 0;
	signal r_120ns_CONVST		: INTEGER range g_120ns_CONVST downto 0 := 0;
	signal r_60ns_CONVST_END	: INTEGER range g_70ns_CONVST_END downto 0 := 0;

begin

	p_CONVST_Generation:
		process (CLK, RST, Q1, i_EOC, r_30us_PWR, r_120ns_CONVST, r_60ns_CONVST_END)
		begin
			
			if (RST <= '0') then
				
				Q1 <= INIT_STATE;
				
				-- OUTPUTS --
				
				r_CONVST <= '1';
				r_30us_PWR <= 0;
				r_120ns_CONVST <= 0;
				r_60ns_CONVST_END <= 0;
				
				--------------
			
			elsif ( rising_edge(CLK) ) then
				
				case Q1 is
				
					when INIT_STATE =>
										
						if (i_EOC = '1') then
					
							Q1 <= PWR_ON_LOW;
							
							-- OUTPUTS --
							
							r_CONVST <= '0';
							r_30us_PWR <= r_30us_PWR + 1;
							
							--------------
				
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '0';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
									
					when PWR_ON_LOW =>	
					
						if ( r_30us_PWR >= g_30us_PWR ) then
						
							Q1 <= CHECK_EOC_1;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '0';
							r_30us_PWR <= r_30us_PWR + 1;
							
							--------------
							
						end if;
			
					when CHECK_EOC_1 =>	
					
						if (i_EOC = '1') then
						
							Q1 <= PWR_ON_HIGH;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= r_30us_PWR + 1;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
									
					when PWR_ON_HIGH =>	
					
						if ( r_30us_PWR >= g_30us_PWR ) then
						
							Q1 <= CHECK_EOC_2;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= r_30us_PWR + 1;
							
							--------------
							
						end if;
					
					when CHECK_EOC_2 =>	
					
						if (i_EOC = '1') then
						
							Q1 <= START_CONVERSION;
							
							-- OUTPUTS --
							
							r_CONVST <= '0';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= r_120ns_CONVST + 1;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
					
					when START_CONVERSION =>	
					
						if ( r_120ns_CONVST >= g_120ns_CONVST ) then
						
							Q1 <= END_CONVERSION_CHECK_1;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '0';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= r_120ns_CONVST + 1;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
						
					when END_CONVERSION_CHECK_1 =>	
					
						if (i_EOC = '0') then
						
							Q1 <= END_CONVERSION_CHECK_2;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
				
					when END_CONVERSION_CHECK_2 =>	
					
						if (i_EOC = '0') then
						
							Q1 <= CHECK_EOC_3;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
					
					when CHECK_EOC_3 =>	
					
						if (i_EOC = '1') then
						
							Q1 <= RE_CHECK_EOC_3;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
												
					when RE_CHECK_EOC_3 =>	
					
						if (i_EOC = '1') then
						
							Q1 <= RESTART_TIME;
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= r_60ns_CONVST_END + 1;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						end if;
									
					when RESTART_TIME =>	
					
						if ( r_60ns_CONVST_END >= g_70ns_CONVST_END ) then
						
							Q1 <= START_CONVERSION;
							
							-- OUTPUTS --
							
							r_CONVST <= '0';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= r_120ns_CONVST + 1;
							r_60ns_CONVST_END <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_CONVST <= '1';
							r_30us_PWR <= 0;
							r_120ns_CONVST <= 0;
							r_60ns_CONVST_END <= r_60ns_CONVST_END + 1;
							
							--------------
							
						end if;
								
				end case;
				
			end if;
					
		end process p_CONVST_Generation;

	------------------ o_CONVST ------------------

	o_CONVST <= r_CONVST;
	
end architecture rtl;