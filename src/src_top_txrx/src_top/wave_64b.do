onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/CLK_50MHZ_I
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/sync
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/rst_in_n
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/refclk_p
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/refclk_n
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/txp
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/txn
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/d_ctrl
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/toggle_ena
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/prbs_ena
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/dc_ena
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/ip_ready
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/lanes_ready
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/err_status
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/valid_status
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/sw1
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/sw2
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/dip1
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/dip2
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/dip3
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/dip4
add wave -noupdate -group tb_top /tb_esistream_62b64b_top/led
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/clk
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/d_ctrl
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/lanes_on
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/frame_out
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/lanes_ready
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/be_status
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/cb_status
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/valid_status
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/sum
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/step
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/data_check_per_ramp
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/data_check_per_lane
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/cb_check_per_lane
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/cb_out_d
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/clk_div
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/data_buf
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/data_out_62b
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/data_out_62b_d
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/lanes_ready_d
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/lanes_ready_buf
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/clk_init
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/frame_out_t
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/lanes_ready_re
add wave -noupdate -group rx_check /tb_esistream_62b64b_top/esistream_62b64b_top_1/txrx_frame_checking_1/lanes_ready_red
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/clk
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/clk_acq
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/rst
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/rd_en
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/din_rdy
add wave -noupdate -group rx_buffer_wrapper -radix hexadecimal /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/din
add wave -noupdate -group rx_buffer_wrapper -radix hexadecimal /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/dout
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/lane_ready
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/wr_en
add wave -noupdate -group rx_buffer_wrapper /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_decoding_gen(0)/rx_lane_decoding_1/rx_buffer_wrapper_1/empty
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/rst_xcvr
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/rx_rstdone
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/xcvr_pll_lock
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/rx_usrclk
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/xcvr_data_rx
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/prbs_ena
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/sync_in
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/clk_acq
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/frame_out
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/valid_out
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/ip_ready
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lanes_ready
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lanes_on
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lane_ready_t
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/lanes_ready_t
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/xcvr_data
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/rst_lane_xcvr
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/ip_lane_ready
add wave -noupdate -expand -group rx_esistream /tb_esistream_62b64b_top/esistream_62b64b_top_1/esistream_tx_rx_1/rx_esistream_1/read_fifo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 261
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {919367 ps} {10477929 ps}
