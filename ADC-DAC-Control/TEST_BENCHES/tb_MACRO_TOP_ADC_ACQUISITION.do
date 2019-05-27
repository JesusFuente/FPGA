vsim work.tb_top_adc_acquisition

add wave -divider top_adc_acquisition
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/CPU_RESET_n
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/OSC_50_B3
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/BUTTON0
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/GPIO0_D_i_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/GPIO0_D10
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/GPIO0_D27
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/GPIO0_D28
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/GPIO0_D29
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/GPIO0_D_DISPLAY
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/LED0

add wave -divider PLL_1
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_PLL_1/areset
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_PLL_1/inclk0
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_PLL_1/c0

add wave -divider ADC_7822
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/RST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/CLK
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/i_calibrate
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/i_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/i_EOC
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/o_CONVST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/o_read
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/o_average_done
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/o_ADC_value
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/o_calibration_LED

add wave -divider clk_convst
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/RST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/CLK
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/Q1
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/r_30us_PWR
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/r_120ns_CONVST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/r_60ns_CONVST_END
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/r_CONVST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/i_EOC
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_clk_convst/o_CONVST

add wave -divider read_adc
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/RST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/CLK
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/t_Q1
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/r_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/r_read
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/r_i_DB_cyc
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/r_EOC
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/i_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/i_EOC
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/o_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_lecture/o_read

add wave -divider average_adc
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/RST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/CLK
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/t_Q1
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/r_averaged_value
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/r_averages_N
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/r_o_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/r_o_average_done
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/i_calibrate
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/i_read
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/i_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/o_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/o_average_done
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_ADC_average/o_calibration_LED

add wave -divider transfer_function_adc
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_Transfer_Function/RST
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_Transfer_Function/CLK
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_Transfer_Function/i_DB
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_Transfer_Function/r_o_ADC_value
add wave -position insertpoint sim:/tb_top_adc_acquisition/inst_TOP_ADC_ACQUISITION/inst_ADC_7822/inst_Transfer_Function/o_ADC_value

run -all