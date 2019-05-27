--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/02/22) (17:07:18)
-- File: WAIT_TO_READ_ADC.vhd
--------------------------------------------------------------
-- Description:
--
-- This vhdl module reads the ADC binray value when EOC signal
-- indicates it and at the same time gets this value out to 
-- send to toher modules to treat the readed values.
--------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity read_adc is
	
	generic(
		g_40ns_EOC			: integer								:= 2		-- T = 40 ns
	);
	
    port(
		CLK 				: in  std_logic;									--	Crystal = 50 MHz
		RST 				: in std_logic;
		i_EOC 				: in std_logic;										-- T(max. LOW) = 370 ns => f(max. HIGH) = 2 702 702,703 Hz ; D = 6 % ; T_on = 22,2 ns ; (SIMULATION)
		i_DB 				: in  std_logic_vector(7 downto 0);
		o_DB 				: out  std_logic_vector(7 downto 0);
        o_read 				: out  std_logic
	);

end entity read_adc;

architecture rtl of read_adc is
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- State signals
	-- -- -- -- -- -- -- -- -- -- -- --
	type STATE_TYPE_1 is (CHECK_ADC_ON, CONVST_DETECTION, WAIT_TO_READ_ADC, READ_ADC, CHECK_ADC_STAT);
	signal t_Q1 : STATE_TYPE_1;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- ADC number read signals
	-- -- -- -- -- -- -- -- -- -- -- --
	signal 		r_DB		: std_logic_vector (7 downto 0);
	signal 		r_read		: std_logic;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Read ADC timer
	-- -- -- -- -- -- -- -- -- -- -- --
	signal 		r_EOC		: integer range g_40ns_EOC downto 0		:= 0;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Counter to stretch the clock cyc of reading i_DB
	-- -- -- -- -- -- -- -- -- -- -- --
	constant 	c_i_DB_cyc	: integer range 10 downto 0				:= 1;
	signal 		r_i_DB_cyc	: integer range c_i_DB_cyc downto 0		:= 0;

begin

	p_ADC_LECTURE:
		process (CLK, RST, t_Q1, i_EOC, i_DB, r_EOC)
		begin
				
			if (RST = '0') then
				
				t_Q1 <= CHECK_ADC_ON;
				
				-- OUTPUTS --
				
				r_DB <= "00000000";
				r_read <= '1';
				r_EOC <= 0;
				r_i_DB_cyc <= 0;
				
				--------------
					
			elsif ( rising_edge(CLK) ) then
					
				case t_Q1 is
			
					when CHECK_ADC_ON =>	
					
						if (i_EOC = '1') then
						
							t_Q1 <= CONVST_DETECTION;
							
							-- OUTPUTS --
							
							r_DB <= r_DB;
							r_read <= '1';
							r_EOC <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_DB <= "00000000";
							r_read <= '1';
							r_EOC <= 0;
							
							--------------
							
						end if;
					
					when CONVST_DETECTION =>	
					
						if (i_EOC = '0') then
						
							t_Q1 <= WAIT_TO_READ_ADC;
							
							-- OUTPUTS --
							
							r_DB <= r_DB;
							r_read <= '1';
				
							r_EOC <= r_EOC + 1;
		
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_DB <= r_DB;
							r_read <= '1';
							r_EOC <= 0;
							
							--------------
							
						end if;
						
					when WAIT_TO_READ_ADC =>	
					
						if ( r_EOC >= g_40ns_EOC ) then
						
							t_Q1 <= READ_ADC;
							
							-- OUTPUTS --

							r_DB <= i_DB;
							r_read <= '0';
							
							r_EOC <= 0;
							
							r_i_DB_cyc <= r_i_DB_cyc + 1;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_DB <= r_DB;
							r_read <= '1';
				
							r_EOC <= r_EOC + 1;
								
							--------------
							
						end if;	
	
					when READ_ADC =>	
						
						if (r_i_DB_cyc = c_i_DB_cyc) then
						
							t_Q1 <= CHECK_ADC_STAT;
			
							-- OUTPUTS --
								
							r_DB <= r_DB;
							r_read <= '1';
							r_EOC <= 0;
							
							r_i_DB_cyc <= 0;
								
							--------------
						
						else
						
							-- OUTPUTS --

							r_DB <= i_DB;
							r_read <= '0';
							
							r_EOC <= 0;
							
							r_i_DB_cyc <= r_i_DB_cyc + 1;
								
							--------------
						
						end if;

					when CHECK_ADC_STAT =>	
					
						if (i_EOC = '1') then
						
							t_Q1 <= CONVST_DETECTION;
							
							-- OUTPUTS --
							
							r_DB <= r_DB;
							r_read <= '1';
							r_EOC <= 0;
							
							--------------
							
						else
							
							-- OUTPUTS --
								
							r_DB <= r_DB;
							r_read <= '1';
							r_EOC <= 0;
								
							--------------
							
						end if;
								
				end case;
			
			end if;
					
		end process p_ADC_LECTURE;

	-- -- -- -- -- -- -- -- -- -- -- --
	-- OUTPUT SIGNALS
	-- -- -- -- -- -- -- -- -- -- -- --
	o_DB <= r_DB;
	o_read <= r_read;
	
end architecture rtl;