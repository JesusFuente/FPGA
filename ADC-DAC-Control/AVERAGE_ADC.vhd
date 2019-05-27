--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/02/23) (10:32:00)
-- File: AVERAGE_ADC.vhd
--------------------------------------------------------------
-- Description:
--
-- This vhdl module averages the intput value readed by the 
-- READ vhdl module. It also contains a calibration mode to
-- lead the user to average the input by a huge quantity to
-- get the DC component of the ADC input.
--------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity average_adc is
	
    port (
		CLK 						: in  std_logic;									--	Crystal = 50 MHz
		RST 						: in std_logic;
		i_read 						: in std_logic;										-- T(max. LOW) = 370 ns => f(max. HIGH) = 2 702 702,703 Hz ; D = 6 % ; T_on = 22,2 ns ; (SIMULATION)
		i_DB 						: in  std_logic_vector(7 downto 0);
		i_calibrate 				: in std_logic;
		o_DB 						: out  std_logic_vector(7 downto 0);
		o_calibration_LED 			: out std_logic;
		o_average_done 				: out  std_logic
	);

end entity average_adc;

architecture rtl of average_adc is

	-- -- -- -- -- -- -- -- -- -- -- --
	-- State Machine 1
	-- -- -- -- -- -- -- -- -- -- -- --
	type state_type_1 is (INIT, CHECK_ADC_READ_ON, CHECK_ADC_READ_DONE, ADC_LECTURE_DONE, ADC_AVERAGE_DONE);
	signal t_Q1 : state_type_1;
	
	signal 		r_o_DB				: std_logic_vector (7 downto 0);
	signal 		r_o_average_done	: std_logic;
	
	signal 		r_averaged_value	: integer								:= 0;
	
	constant	c_max_samples 		: integer range 1048576 downto 0 		:= 1048576;
	constant	c_min_samples 		: integer range 2 downto 0 				:= 2;
	signal 		r_samples_N			: integer range c_max_samples downto 0	:= c_min_samples;
	signal 		r_averages_N		: integer range c_max_samples downto 0	:= 0;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- State Machine 2
	-- -- -- -- -- -- -- -- -- -- -- --
	type state_type_2 is (CAL_INIT, CHECK_CAL_BUTT, CAL_STATE_1, CAL_STATE_2);
	signal t_Q2 : state_type_2;
	

begin

	p_average:
		process (clk, rst, t_Q1, i_read, r_averages_N)
		begin
				
			if (rst = '0') then
				
				t_Q1 <= INIT;
				
				-- OUTPUTS --
				
				r_o_DB <= "00000000";
				r_averaged_value <= 0;
				r_o_average_done <= '1';
				r_averages_N <= 0;
				
				--------------
					
			elsif ( rising_edge(clk) ) then
					
				case t_Q1 is
			
					when INIT =>	
						
						if (i_read = '1') then
						
							t_Q1 <= CHECK_ADC_READ_ON;
							
							-- OUTPUTS --
							
							r_o_DB <= r_o_DB;
							r_averaged_value <= r_averaged_value;
							r_o_average_done <= '1';
							r_averages_N <= r_averages_N;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_o_DB <= "00000000";
							r_averaged_value <= 0;
							r_o_average_done <= '1';
							r_averages_N <= 0;
							
							--------------
							
						end if;
									
					when CHECK_ADC_READ_ON =>	
					
						if (i_read = '1') then
						
							t_Q1 <= CHECK_ADC_READ_DONE;
							
							-- OUTPUTS --
							
							r_o_DB <= r_o_DB;
							r_averaged_value <= r_averaged_value;
							r_o_average_done <= '1';
							r_averages_N <= r_averages_N;
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_o_DB <= r_o_DB;
							r_averaged_value <= r_averaged_value;
							r_o_average_done <= '1';
							r_averages_N <= r_averages_N;
							
							--------------
							
						end if;
									
					when CHECK_ADC_READ_DONE =>	
					
						if (i_read = '0') then
						
							t_Q1 <= ADC_LECTURE_DONE;
							
							-- OUTPUTS --
							
							r_o_DB <= r_o_DB;
							r_averaged_value <= r_averaged_value + to_integer(unsigned(i_DB));
							r_o_average_done <= '1';
							r_averages_N <= r_averages_N + 1;
							
							--------------
						else
							
							-- OUTPUTS --
							
							r_o_DB <= r_o_DB;
							r_averaged_value <= r_averaged_value;
							r_o_average_done <= '1';
							r_averages_N <= r_averages_N;
							
							--------------
							
						end if;
									
					when ADC_LECTURE_DONE =>	
					
						if (r_averages_N < r_samples_N) then
						
							t_Q1 <= CHECK_ADC_READ_ON;
							
							-- OUTPUTS --
							
							r_o_DB <= r_o_DB;
							r_averaged_value <= r_averaged_value;
							r_o_average_done <= '1';
							r_averages_N <= r_averages_N;
							
							--------------
							
						else
						
							t_Q1 <= ADC_AVERAGE_DONE;
							
							-- OUTPUTS --
							
							if (r_samples_N = c_min_samples) then
							
								r_o_DB <= std_logic_vector(to_unsigned(r_averaged_value/c_min_samples, 8));
							
							else
							
								r_o_DB <= std_logic_vector(to_unsigned(r_averaged_value/c_max_samples, 8));
							
							end if;
							
							r_averaged_value <= 0;
							r_o_average_done <= '0';
							r_averages_N <= 0;
							
							--------------
							
						end if;
					
					when ADC_AVERAGE_DONE =>	
					
						t_Q1 <= CHECK_ADC_READ_ON;
							
						-- OUTPUTS --
						
						r_o_DB <= r_o_DB;
						r_averaged_value <= r_averaged_value;
						r_o_average_done <= '1';
						r_averages_N <= r_averages_N;
						
						--------------
						
				end case;
				
			end if;
					
		end process p_average;

	------------------ o_DB ------------------

	o_DB <= r_o_DB;
	o_average_done <= r_o_average_done;
	
	------------------ i_calibrate ------------------
	
	p_calibration:
		process (clk, rst, t_Q2, i_calibrate)
		begin

			if (rst = '0') then
				
				t_Q2 <= CAL_INIT;
				
				-- OUTPUTS --
				
				r_samples_N <= c_min_samples;				-- (1/2 MHz)*1 000 000 = 0,5 s
				o_calibration_LED <= '0';
				
				--------------
					
			elsif ( rising_edge(clk) ) then
				
				case t_Q2 is
			
					when CAL_INIT =>	
					
						if (i_calibrate = '1') then
						
							t_Q2 <= CHECK_CAL_BUTT;
							
							-- OUTPUTS --
							
							r_samples_N <= c_min_samples;
							o_calibration_LED <= '0';
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_samples_N <= c_min_samples;
							o_calibration_LED <= '0';
							
							--------------
							
						end if;
									
					when CHECK_CAL_BUTT =>	
					
						if (i_calibrate = '0') then
						
							t_Q2 <= CAL_STATE_1;
							
							-- OUTPUTS --
							
							r_samples_N <= c_max_samples;
							o_calibration_LED <= '1';
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_samples_N <= c_min_samples;
							o_calibration_LED <= '0';
							
							--------------
							
						end if;
									
					when CAL_STATE_1 =>	
					
						if (i_calibrate = '1') then
						
							t_Q2 <= CAL_STATE_2;
							
							-- OUTPUTS --
							
							r_samples_N <= c_max_samples;
							o_calibration_LED <= '1';
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_samples_N <= c_max_samples;
							o_calibration_LED <= '1';
							
							--------------
							
						end if;
						
					when CAL_STATE_2 =>	
					
						if (i_calibrate = '0') then
						
							t_Q2 <= CAL_INIT;
							
							-- OUTPUTS --
							
							r_samples_N <= c_min_samples;
							o_calibration_LED <= '0';
							
							--------------
							
						else
							
							-- OUTPUTS --
							
							r_samples_N <= c_max_samples;
							o_calibration_LED <= '1';
							
							--------------
							
						end if;
									
				end case;

			end if;

		end process p_calibration;
	
end architecture rtl;