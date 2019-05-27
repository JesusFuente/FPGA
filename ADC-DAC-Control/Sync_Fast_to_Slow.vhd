
--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/03/05) (18:13:30)
-- File: Sync_Fast_to_Slow.vhd
--------------------------------------------------------------
-- Description:
--
-- This vhdl Syncronises an input std_logic_vector to a less
-- fast clock. The output is stretched 
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Sync_Fast_to_Slow is
	
	generic(
		g_i_length					: integer 																	:= 11;
		g_clk_fast_slow_stretch		: integer																	:= 12
	);
	
	port(
		i_RST						: in std_logic;
		i_CLK						: in std_logic;
		--		
		i_DB						: in std_logic_vector(g_i_length-1 downto 0);
		--		
		o_DB						: out std_logic_vector(g_i_length-1 downto 0)
	);
	
end entity Sync_Fast_to_Slow;

architecture rtl of Sync_Fast_to_Slow is

	-- -- -- -- -- -- -- -- -- -- -- --
	-- Sync FF for g_i_length
	-- -- -- -- -- -- -- -- -- -- -- --
	signal 		r_i_DB				: std_logic_vector((i_DB'length-1) downto 0);
	
	constant	c_Counter			: integer range g_clk_fast_slow_stretch downto 0							:= g_clk_fast_slow_stretch;
	type t_Counters is array (0 to (i_DB'length-1)) of integer range c_Counter-1 downto 0;
	signal 		r_Counter			: t_Counters 											:= (others => 0);
	
begin

	gen_Sync_i_DB:
		
		for i in i_DB'length-1 downto 0 generate
			
			p_Sync_GPIO0_D_DISPLAY:
				process (i_RST, i_CLK, i_DB, r_Counter)
				begin
				
					if (i_RST = '0') then
					
						r_i_DB(i) <= '0';
						r_Counter(i) <= 0;
					
					elsif (rising_edge(i_CLK)) then
						
						if (r_Counter(i) = 0) then
						
							r_i_DB(i) <= i_DB(i);
							
							if ((r_i_DB(i) = '0') and (i_DB(i) = '1')) then	-- risign_edge detection
								
								r_i_DB(i) <= '1';
								r_Counter(i) <= r_Counter(i) + 1;
							
							elsif ((r_i_DB(i) = '1') and (i_DB(i) = '0')) then	-- falling_edge detection
							
								r_i_DB(i) <= '0';
								r_Counter(i) <= r_Counter(i) + 1;
							
							end if;
						
						else

							if (r_Counter(i) = c_Counter-1) then
						
								r_Counter(i) <= 0;
								
							else
							
								r_Counter(i) <= r_Counter(i) + 1;
							
							end if;

						end if;
					
					end if;
				
				end process;
		
		end generate gen_Sync_i_DB;
	
	concurrent_logic_Sync_Fast_to_Slow:
		o_DB <= r_i_DB;
	
end architecture rtl;