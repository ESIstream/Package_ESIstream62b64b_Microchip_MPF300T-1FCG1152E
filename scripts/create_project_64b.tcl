set Proj "esistream_62b64b_64b"
set family "PolarFire"
set die "MPF300T"
set package "FCG1152"
set hdl "VHDL"
set speed -1
set die_voltage 1.0
set OS     $tcl_platform(os)
set err     {0}
set Msg {Errors :0}

set ls_ch [open "project_check_status.txt" w+]

proc grepPattern { ex dumped_file } \
{
    set f_id [open $dumped_file]
    while {[eof $f_id]==0} \
    {
        set line_tokens [gets $f_id]
        if {[regexp $ex "$line_tokens"]==1} \
        {
            puts "Pattern $ex found"
            close $f_id
            return 1
        }
    }
    puts "Pattern $ex not found"
    close $f_id
    return 0
}


file delete -force ./../$Proj

new_project     -instantiate_in_smartdesign 1 \
                -ondemand_build_dh 1 \
                -use_enhanced_constraint_flow 1 \
                -location "./../$Proj" \
                -name $Proj \
                -hdl $hdl \
                -family $family \
                -die $die \
                -package $package \
                -speed $speed \
                -die_voltage $die_voltage

create_links \
         -convert_EDN_to_HDL 0 \
         -library {work} \
         -hdl_source {./../src/src_common/data_gen.vhd} \
         -hdl_source {./../src/src_common/delay.vhd} \
         -hdl_source {./../src/src_common/delay2.vhd} \
         -hdl_source {./../src/src_common/ff_synchronizer_array.vhd} \
         -hdl_source {./../src/src_common/meta.vhd} \
         -hdl_source {./../src/src_common/meta_re.vhd} \
         -hdl_source {./../src/src_common/sysreset.vhd} \
         -hdl_source {./../src/src_common/debouncer.vhd} \
         -hdl_source {./../src/src_common/risingedge.vhd} \
         -hdl_source {./../src/src_common/two_flop_synchronizer.vhd} \
         -hdl_source {./../src/src_common/txrx_frame_checking.vhd} \
         -hdl_source {./../src/src_common/component6264_pkg_64.vhd} \
         -hdl_source {./../src/src_esistream/esistream6264_pkg_6464.vhd} \
         -hdl_source {./../src/src_esistream/rx_fifo_dc.vhd} \
         -hdl_source {./../src/src_esistream/rx_ram_dual_clock.vhd} \
         -hdl_source {./../src/src_esistream/rx_decoder.vhd} \
         -hdl_source {./../src/src_esistream/rx_esistream.vhd} \
         -hdl_source {./../src/src_esistream/rx_frame_alignment.vhd} \
         -hdl_source {./../src/src_esistream/rx_lane_decoding.vhd} \
         -hdl_source {./../src/src_esistream/rx_lfsr_init.vhd} \
         -hdl_source {./../src/src_esistream/rx_buffer_wrapper_64b.vhd} \
         -hdl_source {./../src/src_esistream/tx_disparity.vhd} \
         -hdl_source {./../src/src_esistream/tx_lane_encoding.vhd} \
         -hdl_source {./../src/src_esistream/tx_esistream.vhd} \
         -hdl_source {./../src/src_esistream/tx_lfsr.vhd} \
         -hdl_source {./../src/src_esistream/tx_scrambling.vhd} \
         -hdl_source {./../src/src_esistream/tx_sm.vhd} \
         -hdl_source {./../src/src_esistream/esistream_tx_rx.vhd} \
         -hdl_source {./../src/src_esistream/tx_rx_xcvr_wrapper_64b64b.vhd} \
         -hdl_source {./../src/src_top_txrx/src_top/esistream_62b64b_top.vhd} \
         -stimulus {./../src/src_top_txrx/src_top/tb_esistream_62b64b_top.vhd}\
         -io_pdc {./../src/src_top_txrx/constraints/constraints.pdc}\
         -fp_pdc {./../src/src_top_txrx/constraints/fp_64.pdc}\
         -sdc {./../src/src_top_txrx/constraints/esistream_62b64b_top_derived_constraints_64.sdc}
         


source ./../src/src_ip/PF_TX_PLL_C0.tcl
source ./../src/src_ip/PF_TX_PLL_C1.tcl
source ./../src/src_ip/PF_CCC_C0.tcl
# source ./../src/src_ip/PF_CCC_C1.tcl
source ./../src/src_ip/PF_XCVR_ERM_C2.tcl
source ./../src/src_ip/PF_XCVR_ERM_C3.tcl
source ./../src/src_ip/PF_XCVR_REF_CLK_C0.tcl


generate_component -component_name {PF_CCC_C0}
# generate_component -component_name {PF_CCC_C1}
generate_component -component_name {PF_XCVR_ERM_C2}
generate_component -component_name {PF_XCVR_ERM_C3}
generate_component -component_name {PF_XCVR_REF_CLK_C0}
generate_component -component_name {PF_TX_PLL_C0}
generate_component -component_name {PF_TX_PLL_C1}


build_design_hierarchy 
set_root -module {esistream_62b64b_top::work} 

open_project -file {./../esistream_62b64b_64b/esistream_62b64b_64b.prjx}

organize_tool_files -tool {SYNTHESIZE} \
                    -file {./../src/src_top_txrx/constraints/esistream_62b64b_top_derived_constraints_64.sdc} \
                    -input_type {constraint}

organize_tool_files -tool {PLACEROUTE} \
                    -file {./../src/src_top_txrx/constraints/constraints.pdc} \
                    -file {./../src/src_top_txrx/constraints/esistream_62b64b_top_derived_constraints_64.sdc} \
                    -file {./../src/src_top_txrx/constraints/fp_64.pdc} \
                    -input_type {constraint}
organize_tool_files \
         -tool {VERIFYTIMING} \
         -file {./../src/src_top_txrx/constraints/esistream_62b64b_top_derived_constraints_64.sdc} \
         -input_type {constraint}

configure_tool -name {PLACEROUTE}   \
   -params {TDPR:true}              \
   -params {EFFORT_LEVEL:true}      \
   -params {REPLICATION:true}      \
   -params {REPAIR_MIN_DELAY:true}

puts $ls_ch "PROJECT CREATED"

save_project
close_project
