# Microsemi Corp.
# Date: 2022-Nov-25 14:59:07
# This file was generated based on the following SDC source files:
#   C:/Users/bahri/Desktop/e2v_esistream/FPGA/project_62_64bits/esistream_62b64b_32b/component/work/PF_CCC_C0/PF_CCC_C0_0/PF_CCC_C0_PF_CCC_C0_0_PF_CCC.sdc
#   C:/Users/bahri/Desktop/e2v_esistream/FPGA/project_62_64bits/esistream_62b64b_32b/component/work/PF_CCC_C1/PF_CCC_C1_0/PF_CCC_C1_PF_CCC_C1_0_PF_CCC.sdc
#   C:/Users/bahri/Desktop/e2v_esistream/FPGA/project_62_64bits/esistream_62b64b_32b/component/work/PF_TX_PLL_C0/PF_TX_PLL_C0_0/PF_TX_PLL_C0_PF_TX_PLL_C0_0_PF_TX_PLL.sdc
#   C:/Users/bahri/Desktop/e2v_esistream/FPGA/project_62_64bits/esistream_62b64b_32b/component/work/PF_TX_PLL_C1/PF_TX_PLL_C1_0/PF_TX_PLL_C1_PF_TX_PLL_C1_0_PF_TX_PLL.sdc
#   C:/Users/bahri/Desktop/e2v_esistream/FPGA/project_62_64bits/esistream_62b64b_32b/component/work/PF_XCVR_ERM_C0/I_XCVR/PF_XCVR_ERM_C0_I_XCVR_PF_XCVR.sdc
#   C:/Users/bahri/Desktop/e2v_esistream/FPGA/project_62_64bits/esistream_62b64b_32b/component/work/PF_XCVR_ERM_C1/I_XCVR/PF_XCVR_ERM_C1_I_XCVR_PF_XCVR.sdc
#

create_clock -name {CLK_50MHZ_I} -period 20 [ get_ports { CLK_50MHZ_I } ]
create_clock -name {refclk_p} -period 6.4 [ get_ports { refclk_p } ]
create_clock -name {LANE0_1_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_1/I_XCVR/LANE0/RX_CLK_R } ]
create_clock -name {LANE1_1_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_1/I_XCVR/LANE1/RX_CLK_R } ]
create_clock -name {LANE2_1_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_1/I_XCVR/LANE2/RX_CLK_R } ]
create_clock -name {LANE3_1_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_1/I_XCVR/LANE3/RX_CLK_R } ]
create_clock -name {LANE0_2_Y_DIV}    -period 6.4 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_2/I_XCVR/LANE0_TX_IcbClkDiv/Y_DIV } ]
create_clock -name {LANE0_2_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_2/I_XCVR/LANE0/RX_CLK_R } ]
create_clock -name {LANE1_2_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_2/I_XCVR/LANE1/RX_CLK_R } ]
create_clock -name {LANE2_2_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_2/I_XCVR/LANE2/RX_CLK_R } ]
create_clock -name {LANE3_2_RX_CLK_R} -period 3.2 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_txrx_4lanes_32b_2/I_XCVR/LANE3/RX_CLK_R } ]
create_generated_clock -name CLK_SYS -multiply_by 2 -source [ get_pins { i_pll_sys/PF_CCC_C0_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { i_pll_sys/PF_CCC_C0_0/pll_inst_0/OUT0 } ]
create_generated_clock -name {CLK_150MHz} -multiply_by 3 -source [ get_pins { i_pll_sys/PF_CCC_C0_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { i_pll_sys/PF_CCC_C0_0/pll_inst_0/OUT1 } ]
create_generated_clock -name CLK_FRAME -multiply_by 2 -source [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_frame_clk/PF_CCC_C1_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { esistream_tx_rx_1/xcvr_wrapper_1/i_frame_clk/PF_CCC_C1_0/pll_inst_0/OUT0 } ]
set_false_path -through [ get_pins { i_pll_sys/PF_CCC_C0_0/pll_inst_0/OUT0 } ] -to [ get_cells { i_pll_sys/PF_CCC_C0_0/Pll_Ext_FeedBack_Mode_Soft_Logic_Inst/* } ]
set_clock_groups -asynchronous -group {LANE0_1_RX_CLK_R} \
                               -group {LANE1_1_RX_CLK_R} \
                               -group {LANE2_1_RX_CLK_R} \
                               -group {LANE3_1_RX_CLK_R} \
                               -group {LANE0_2_RX_CLK_R} \
                               -group {LANE0_2_Y_DIV}    \
                               -group {LANE1_2_RX_CLK_R} \
                               -group {LANE2_2_RX_CLK_R} \
                               -group {LANE3_2_RX_CLK_R} \
                               -group {CLK_SYS         } \
                               -group {CLK_150MHz      } \
                               -group {CLK_FRAME       } \
                               -group {CLK_50MHZ_I}      \
                               -group {refclk_p}
