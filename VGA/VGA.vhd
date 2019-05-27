--------------------------------------------------------------
-- Project: TFG
-- Author: Jesús Fuente Porta
-- Date: (2019/03/03) (11:27:12)
-- File: VGA.vhd
--------------------------------------------------------------
-- Description:
--
-- This is the top vhdl module for VGA display.
--------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is

	generic(
		g_VIDEO_WIDTH				: integer 											:= 4;
		g_TOTAL_COLS  				: integer											:= 800;
		g_TOTAL_ROWS  				: integer											:= 525;
		g_ACTIVE_COLS 				: integer											:= 640;
		g_ACTIVE_ROWS 				: integer											:= 480;
		g_Clk_Div					: integer											:= 2	
	);			
				
	port(			
		i_RST						: in std_logic;
		i_Clk       				: in  std_logic;
		i_Pattern_Sel				: in std_logic_vector(3 downto 0);
		o_R							: out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
		o_G							: out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
		o_B							: out std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
		o_HSync     				: out std_logic;
		o_VSync     				: out std_logic
	);

end entity vga;

architecture structural of vga is

	signal r_Clk_Div				: integer range g_Clk_Div downto 0					:= 0;

	signal w_HSync_VGA_Sync_Pulses 	: std_logic;
	signal w_VSync_VGA_Sync_Pulses 	: std_logic;
	
	signal w_HSync_Pattern_Gen 		: std_logic;
	signal w_VSync_Pattern_Gen 		: std_logic;
	
	signal w_HSync_VGA_Sync_Porch 	: std_logic;
	signal w_VSync_VGA_Sync_Porch 	: std_logic;
	
	signal w_o_R_Pattern_Gen 		: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	signal w_o_G_Pattern_Gen 		: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	signal w_o_B_Pattern_Gen 		: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	
	signal w_o_R_VGA_Sync_Porch		: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	signal w_o_G_VGA_Sync_Porch		: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	signal w_o_B_VGA_Sync_Porch		: std_logic_vector(g_VIDEO_WIDTH-1 downto 0);
	
	constant c_Sync_n				: integer range 2 downto 0							:= 2;
	type t_Sync_Chain_1 is array (0 to i_Pattern_Sel'length) of std_logic_vector(c_Sync_n-1 downto 0);
	signal r_Sync_i_Pattern_Sel		: t_Sync_Chain_1;
	signal w_i_Pattern				: std_logic_vector(i_Pattern_Sel'length-1 downto 0);

begin

	inst_VGA_Sync_Pulses:
		entity work.VGA_Sync_Pulses(rtl)
		generic map(
			g_TOTAL_COLS => g_TOTAL_COLS,
			g_TOTAL_ROWS => g_TOTAL_ROWS,
			g_ACTIVE_COLS => g_ACTIVE_COLS,
			g_ACTIVE_ROWS => g_ACTIVE_ROWS,
			g_Clk_Div => g_Clk_Div
		)
		port map(
			i_RST => i_RST,
			i_Clk => i_Clk,
			o_HSync => w_HSync_VGA_Sync_Pulses,
			o_VSync => w_VSync_VGA_Sync_Pulses
		);

	inst_Pattern_Gen:
		entity work.Pattern_Gen(rtl)
		generic map(
			g_VIDEO_WIDTH => g_VIDEO_WIDTH,
			g_TOTAL_COLS => g_TOTAL_COLS,
			g_TOTAL_ROWS => g_TOTAL_ROWS,
			g_ACTIVE_COLS => g_ACTIVE_COLS,
			g_ACTIVE_ROWS => g_ACTIVE_ROWS,
			g_Clk_Div => g_Clk_Div
		)
		port map(
			i_RST => i_RST,
			i_Clk => i_Clk,
			i_Pattern => w_i_Pattern,
			i_HSync => w_HSync_VGA_Sync_Pulses,
			i_VSync => w_VSync_VGA_Sync_Pulses,
			o_HSync => w_HSync_Pattern_Gen,
			o_VSync => w_VSync_Pattern_Gen,
			o_R => w_o_R_Pattern_Gen,
			o_G => w_o_G_Pattern_Gen,
			o_B => w_o_B_Pattern_Gen
		);
		
	inst_VGA_Sync_Porch:
		entity work.VGA_Sync_Porch(rtl)
		generic map(
			g_VIDEO_WIDTH => g_VIDEO_WIDTH,
			g_TOTAL_COLS => g_TOTAL_COLS,
			g_TOTAL_ROWS => g_TOTAL_ROWS,
			g_ACTIVE_COLS => g_ACTIVE_COLS,
			g_ACTIVE_ROWS => g_ACTIVE_ROWS,
			g_Clk_Div => g_Clk_Div
		)
		port map(
			i_RST => i_RST,
			i_Clk => i_Clk,
			i_HSync => w_HSync_Pattern_Gen, 
			i_VSync => w_VSync_Pattern_Gen,
			i_Red_Video => w_o_R_Pattern_Gen,
			i_Grn_Video => w_o_G_Pattern_Gen,
			i_Blu_Video => w_o_B_Pattern_Gen,
			o_HSync => w_HSync_VGA_Sync_Porch,
			o_VSync => w_VSync_VGA_Sync_Porch,
			o_Red_Video => w_o_R_VGA_Sync_Porch,
			o_Grn_Video => w_o_G_VGA_Sync_Porch,
			o_Blu_Video => w_o_B_VGA_Sync_Porch
		);
		
	concurrent_logic_VGA_Sync_Porch:
		o_HSync <= w_HSync_VGA_Sync_Porch;
		o_VSync <= w_VSync_VGA_Sync_Porch;
		
		o_R <= w_o_R_VGA_Sync_Porch;
		o_G <= w_o_G_VGA_Sync_Porch;
        o_B <= w_o_B_VGA_Sync_Porch;
		
	p_Sync_i_Pattern_Sel:
		process (i_RST, i_Clk, r_Clk_Div, i_Pattern_Sel)
		begin
		
			if (i_RST = '0') then
				
				r_Clk_Div <= 0;
				
				l_Sync_i_Pattern_Sel_3:
					for i in (i_Pattern_Sel'length-1) downto 0 loop
					
						r_Sync_i_Pattern_Sel(i) <= (others => '0');
					
					end loop l_Sync_i_Pattern_Sel_3;
			
			elsif (rising_edge(i_Clk)) then
				
				if (r_Clk_Div = g_Clk_Div-1) then
					
					r_Clk_Div <= 0;
					
					l_Sync_i_Pattern_Sel_1:
						for i in (i_Pattern_Sel'length-1) downto 0 loop
						
							r_Sync_i_Pattern_Sel(i)(0) <= i_Pattern_Sel(i);

							r_Sync_i_Pattern_Sel(i)(1) <= r_Sync_i_Pattern_Sel(i)(0);
						
						end loop l_Sync_i_Pattern_Sel_1;
				
				else
				
					r_Clk_Div <= r_Clk_Div + 1;
				
				end if;
			
			end if;
		
		end process p_Sync_i_Pattern_Sel;
		
	gen_Sync_i_Pattern_Sel:
		for i in (i_Pattern_Sel'length-1) downto 0 generate
		
			w_i_Pattern(i) <= r_Sync_i_Pattern_Sel(i)(c_Sync_n-1);
		
		end generate gen_Sync_i_Pattern_Sel;			
		
end architecture structural;