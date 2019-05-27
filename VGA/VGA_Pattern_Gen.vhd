--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/03/03) (13:59:35)
-- File: Pattern_Gen.vhd
--------------------------------------------------------------
-- Description:
--
-- This module is designed for 640x480 with a 25 MHz input
-- clock. All test patterns are being generated all the time. 
-- This makes use of one of the benefits of FPGAs, they are
-- highly parallelizable.  Many different things can all be
-- happening at the same time.  In this case, there are
-- several test patterns that are being generated
-- simulatenously.  The actual choice of which test pattern
-- gets displayed is done via the i_Pattern signal, which is
-- an input to a case statement.

-- Available Patterns:
-- Pattern 0: Disables the Test Pattern Generator
-- Pattern 1: All Red
-- Pattern 2: All Green
-- Pattern 3: All Blue
-- Pattern 4: Checkerboard white/black
-- Pattern 5: Color Bars
-- Pattern 6: White Box with Border (2 pixels)
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Pattern_Gen is

	generic (
		g_VIDEO_WIDTH				: integer 																	:= 4;
		g_TOTAL_COLS  				: integer 																	:= 800;
		g_TOTAL_ROWS  				: integer 																	:= 525;
		g_ACTIVE_COLS 				: integer 																	:= 640;
		g_ACTIVE_ROWS 				: integer 																	:= 480;
		g_Clk_Div					: integer 																	:= 2
	);			
	port (			
		i_RST						: in std_logic;
		i_Clk     					: in std_logic;
		i_Pattern 					: in std_logic_vector(3 downto 0);
		i_HSync   					: in std_logic;
		i_VSync   					: in std_logic;
		--				
		o_HSync     				: out std_logic;
		o_VSync     				: out std_logic;
		o_R 						: out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
		o_G 						: out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
		o_B 						: out std_logic_vector(g_VIDEO_WIDTH-1 downto 0)
	);
	
end entity Pattern_Gen;

architecture rtl of Pattern_Gen is
	
	signal r_Clk_Div				: integer range g_Clk_Div downto 0										:= 0;
	
	signal w_VSync 					: std_logic;
	signal w_HSync 					: std_logic;
	signal r_o_VSync				: std_logic;
	signal r_o_HSync				: std_logic;
	
	signal r_o_R 					: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	signal r_o_G 					: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	signal r_o_B 					: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Create a type that contains all Test Patterns.
	-- Patterns have 16 indexes (0 to 15) and can be g_VIDEO_WIDTH bits wide
	-- -- -- -- -- -- -- -- -- -- -- --
	constant n_patterns_available	: integer range 15 downto 0 											:= 15;
	type t_Patterns is array (0 to n_patterns_available) of std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	signal Pattern_Red 				: t_Patterns;
	signal Pattern_Grn 				: t_Patterns;
	signal Pattern_Blu 				: t_Patterns;
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Special drawing sets
	-- -- -- -- -- -- -- -- -- -- -- --
	signal w_Bar_Width  			: integer range g_ACTIVE_COLS/8 downto 0;
	signal w_Bar_Select 			: integer range 7 downto 0;  -- Color Bars
	
	-- -- -- -- -- -- -- -- -- -- -- --
	-- Make these unsigned counters (always positive)
	-- -- -- -- -- -- -- -- -- -- -- --
	signal w_Col_Count 			: std_logic_vector(9 downto 0);
	signal w_Row_Count 			: std_logic_vector(9 downto 0);
  
begin

	inst_Sync_Count:
		entity work.Sync_Count(rtl)
		generic map (
			g_TOTAL_COLS 	=> g_TOTAL_COLS,
			g_TOTAL_ROWS 	=> g_TOTAL_ROWS,
			g_Clk_Div 		=> g_Clk_Div
		)
		port map (
			i_RST 			=> i_RST,
			i_Clk       	=> i_Clk,
			i_HSync     	=> i_HSync,
			i_VSync     	=> i_VSync,
			o_HSync     	=> w_HSync,
			o_VSync     	=> w_VSync,
			o_Col_Count 	=> w_Col_Count,
			o_Row_Count 	=> w_Row_Count
		);
	
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

				r_o_VSync <= '0';
				r_o_HSync <= '0';

			elsif rising_edge(i_Clk) then
				
				if (r_Clk_Div = g_Clk_Div-1) then
				
					r_o_VSync <= w_VSync;
					r_o_HSync <= w_HSync;

				end if;

			end if;

		end process p_Reg_Syncs; 
	  
	concurrent_logic:
		o_VSync <= r_o_VSync;
		o_HSync <= r_o_HSync;
	
	-----------------------------------------------------------------------------
	-- Pattern 0: Disables the Test Pattern Generator
	-----------------------------------------------------------------------------
	Pattern_Red(0) <= 	(others => '0');
	Pattern_Grn(0) <= 	(others => '0');
	Pattern_Blu(0) <= 	(others => '0');
  
	-----------------------------------------------------------------------------
	-- Pattern 1: All Red
	-----------------------------------------------------------------------------
	Pattern_Red(1) <= 	(others => '1') when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
											to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
						(others => '0');

	Pattern_Grn(1) <= 	(others => '0');
	Pattern_Blu(1) <= 	(others => '0');

	-----------------------------------------------------------------------------
	-- Pattern 2: All Green
	-----------------------------------------------------------------------------
	Pattern_Red(2) <= 	(others => '0');
	Pattern_Grn(2) <= 	(others => '1') when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
											to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
						(others => '0');
	Pattern_Blu(2) <= 	(others => '0');
  
	-----------------------------------------------------------------------------
	-- Pattern 3: All Blue
	-----------------------------------------------------------------------------
	Pattern_Red(3) <= 	(others => '0');
	Pattern_Grn(3) <= 	(others => '0');
	Pattern_Blu(3) <= 	(others => '1') when (to_integer(unsigned(w_Col_Count)) < g_ACTIVE_COLS and 
											to_integer(unsigned(w_Row_Count)) < g_ACTIVE_ROWS) else
						(others => '0');

	-----------------------------------------------------------------------------
	-- Pattern 4: Checkerboard white/black
	-----------------------------------------------------------------------------
	Pattern_Red(4) <= 	(others => '1') when (w_Col_Count(5) = '0' xor	-- We do 32x32 alternatively white
										w_Row_Count(5) = '1') else		-- and black squares (We take advantage
						(others => '0');								-- of counter properties)

	Pattern_Grn(4) <= 	Pattern_Red(4);
	Pattern_Blu(4) <= 	Pattern_Red(4);
  
  
	-----------------------------------------------------------------------------
	-- Pattern 5: Color Bars
	-- Divides active area into 8 Equal Bars and colors them accordingly
	-- Colors Each According to this Truth Table:
	-- R G B  w_Bar_Select  Ouput Color
	-- 0 0 0       0        Black
	-- 0 0 1       1        Blue
	-- 0 1 0       2        Green
	-- 0 1 1       3        Turquoise
	-- 1 0 0       4        Red
	-- 1 0 1       5        Purple
	-- 1 1 0       6        Yellow
	-- 1 1 1       7        White
	-----------------------------------------------------------------------------
	w_Bar_Width <= g_ACTIVE_COLS/8;

	w_Bar_Select <= 0 when unsigned(w_Col_Count) < w_Bar_Width*1 else
					  1 when unsigned(w_Col_Count) < w_Bar_Width*2 else
					  2 when unsigned(w_Col_Count) < w_Bar_Width*3 else
					  3 when unsigned(w_Col_Count) < w_Bar_Width*4 else
					  4 when unsigned(w_Col_Count) < w_Bar_Width*5 else
					  5 when unsigned(w_Col_Count) < w_Bar_Width*6 else
					  6 when unsigned(w_Col_Count) < w_Bar_Width*7 else
					  7;

	-- Implement Truth Table above with Conditional Assignments
	Pattern_Red(5) <= 	(others => '1') when (w_Bar_Select = 4 or w_Bar_Select = 5 or
										w_Bar_Select = 6 or w_Bar_Select = 7) else
						(others => '0');

	Pattern_Grn(5) <= 	(others => '1') when (w_Bar_Select = 2 or w_Bar_Select = 3 or
										w_Bar_Select = 6 or w_Bar_Select = 7) else
						(others => '0');

	Pattern_Blu(5) <= 	(others => '1') when (w_Bar_Select = 1 or w_Bar_Select = 3 or
										w_Bar_Select = 5 or w_Bar_Select = 7) else
						(others => '0');


	-----------------------------------------------------------------------------
	-- Pattern 6: Black With White Border
	-- Creates a black screen with a white border 2 pixels wide around outside.
	-----------------------------------------------------------------------------
	Pattern_Red(6) <= 	(others => '1') when (to_integer(unsigned(w_Row_Count)) <= 1 or
										to_integer(unsigned(w_Row_Count)) >= g_ACTIVE_ROWS-1-1 or
										to_integer(unsigned(w_Col_Count)) <= 1 or
										to_integer(unsigned(w_Col_Count)) >= g_ACTIVE_COLS-1-1) else
						(others => '0');

	Pattern_Grn(6) <= Pattern_Red(6);
	Pattern_Blu(6) <= Pattern_Red(6);

	-----------------------------------------------------------------------------
	-- Select between different test patterns
	-----------------------------------------------------------------------------
	p_Pattern_Select:
		process (i_RST, i_Clk, r_Clk_Div, i_Pattern, Pattern_Red, Pattern_Grn, Pattern_Blu)
		begin
			
			if (i_RST = '0') then
			
				r_o_R <= Pattern_Red(0);
				r_o_G <= Pattern_Red(0);
				r_o_B <= Pattern_Blu(0);
			
			elsif rising_edge(i_Clk) then
			
				if (r_Clk_Div = g_Clk_Div-1) then
			
					case i_Pattern is
				  
						when "0000" =>
							r_o_R <= Pattern_Red(0);
							r_o_G <= Pattern_Grn(0);
							r_o_B <= Pattern_Blu(0);
							
						when "0001" =>
							r_o_R <= Pattern_Red(1);
							r_o_G <= Pattern_Grn(1);
							r_o_B <= Pattern_Blu(1);
							
						when "0010" =>
							r_o_R <= Pattern_Red(2);
							r_o_G <= Pattern_Grn(2);
							r_o_B <= Pattern_Blu(2);
							
						when "0011" =>
							r_o_R <= Pattern_Red(3);
							r_o_G <= Pattern_Grn(3);
							r_o_B <= Pattern_Blu(3);
							
						when "0100" =>
							r_o_R <= Pattern_Red(4);
							r_o_G <= Pattern_Grn(4);
							r_o_B <= Pattern_Blu(4);
							
						when "0101" =>
							r_o_R <= Pattern_Red(5);
							r_o_G <= Pattern_Grn(5);
							r_o_B <= Pattern_Blu(5);
							
						when "0110" =>
							r_o_R <= Pattern_Red(6);
							r_o_G <= Pattern_Grn(6);
							r_o_B <= Pattern_Blu(6);
							
						when others =>
						  r_o_R <= Pattern_Red(0);
						  r_o_G <= Pattern_Grn(0);
						  r_o_B <= Pattern_Blu(0);
					  
					end case;
				
				end if;
				
			end if;
			
		end process p_Pattern_Select;
		
	w_Color_Selectors:
		o_R <= r_o_R;
		o_G <= r_o_G;
		o_B <= r_o_B;

end architecture rtl;