--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/03/03) (11:57:39)
-- File: Sync_Count.vhd
--------------------------------------------------------------
-- Description:
--
-- This module will take incoming horizontal and veritcal
-- sync pulses and will create Row and Column counters based
-- on these syncs. It will align the Row/Col counters to the
-- output Sync pulses. Useful for any module that needs to
-- keep track of which Row/Col position we are on in the
-- middle of a frame.
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Sync_Count is

	generic (
		g_TOTAL_COLS  	: integer								:= 800;
		g_TOTAL_ROWS  	: integer								:= 525;
		g_Clk_Div		: integer								:= 2
    );
	port (
		i_RST			: in std_logic;
		i_Clk     		: in std_logic;
		i_HSync   		: in std_logic;
		i_VSync   		: in std_logic;
	  
		o_HSync     	: out std_logic;
		o_VSync     	: out std_logic;
		o_Col_Count 	: out std_logic_vector(9 downto 0);
		o_Row_Count 	: out std_logic_vector(9 downto 0)
    );
	
end entity Sync_Count;

architecture rtl of Sync_Count is
	
	signal r_Clk_Div	: integer range g_Clk_Div downto 0		:= 0;
	
	signal r_VSync       : std_logic;
	signal r_HSync       : std_logic;
	signal w_Frame_Start : std_logic;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Make these unsigned counters (always positive)
	-- -- -- -- -- -- -- -- -- -- -- --
	signal r_Col_Count 	: integer range g_TOTAL_COLS-1 downto 0	:= 0;
	signal r_Row_Count 	: integer range g_TOTAL_ROWS-1 downto 0 := 0;

begin
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Process to generate a divided clock
	-- -- -- -- -- -- -- -- -- -- -- --
	p_Clk_Div:
		process (i_RST, i_Clk, r_Clk_Div)
		begin
		
			if (i_RST = '0') then
			
				r_Clk_Div <= 0;
			
			elsif (rising_edge(i_Clk)) then
			
				if (r_Clk_Div = g_Clk_Div-1) then
				
					r_Clk_Div <= 0;
				
				else
				
					r_Clk_Div <= r_Clk_Div + 1;
				
				end if;
			
			end if;
		
		end process p_Clk_Div;

	-- -- -- -- -- -- -- -- -- -- -- --
	-- Register syncs to align with output data.
	-- -- -- -- -- -- -- -- -- -- -- --
	p_Reg_Syncs:
		process (i_RST, i_Clk, r_Clk_Div)
		begin
		
			if (i_RST = '0') then
			
				r_VSync <= '0';
				r_HSync <= '0';
			
			elsif (rising_edge(i_Clk)) then
				
				if (r_Clk_Div = g_Clk_Div-1) then
					
					r_VSync <= i_VSync;
					r_HSync <= i_HSync;
				
				end if;
			  
			end if;
		
		end process p_Reg_Syncs; 

	-- -- -- -- -- -- -- -- -- -- -- --
	-- Keep track of Row/Column counters.
	-- -- -- -- -- -- -- -- -- -- -- --
	p_Row_Col_Count:
		process (i_RST, i_Clk, r_Clk_Div, w_Frame_Start, r_Col_Count, r_Row_Count)
		begin
		
			if (i_RST = '0') then
			
				r_Col_Count <= 0;
				r_Row_Count <= 0;
			
			elsif (rising_edge(i_Clk)) then
			
				if (r_Clk_Div = g_Clk_Div-1) then
					
					if (w_Frame_Start = '1') then
					
						r_Col_Count <= 0;
						r_Row_Count <= 0;
					
					elsif (r_Col_Count = g_TOTAL_COLS-1) then
						
						r_Col_Count <= 0;
						
						if (r_Row_Count = g_TOTAL_ROWS-1) then
						
							r_Row_Count <= 0;
						
						else
						
							r_Row_Count <= r_Row_Count + 1;
						
						end if;
					
					else
					
						r_Col_Count <= r_Col_Count + 1;
						
					end if;
				
				end if;
				
			end if;
			
		end process p_Row_Col_Count;
  
    concurrent_logic:
		-- -- -- -- -- -- -- -- -- -- -- --
		-- Look for rising edge on Vertical Sync to reset the counters
		-- -- -- -- -- -- -- -- -- -- -- --
		w_Frame_Start <= 	'1' when (r_VSync = '0' and i_VSync = '1') else
							'0';
		
		-- -- -- -- -- -- -- -- -- -- -- --
		-- Vertical and Horitzontal wires
		-- -- -- -- -- -- -- -- -- -- -- --		
		o_VSync <= r_VSync;
		o_HSync <= r_HSync;

		-- -- -- -- -- -- -- -- -- -- -- --
		-- Counters
		-- -- -- -- -- -- -- -- -- -- -- --
		o_Row_Count <= std_logic_vector(to_unsigned(r_Row_Count, o_Row_Count'length));
		o_Col_Count <= std_logic_vector(to_unsigned(r_Col_Count, o_Col_Count'length));
  
end architecture rtl;