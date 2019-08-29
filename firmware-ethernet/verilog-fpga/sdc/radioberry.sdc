set_time_format -unit ns -decimal_places 3

create_clock -name phy_clk -period 20.000 [get_ports phy_clk]

create_clock -name clk_76m8 -period 76.800MHz [get_ports clk_76m8]

create_clock -name virt_ad9866_rxclk_rx -period 153.600MHz
create_clock -name virt_ad9866_rxclk_tx -period 153.600MHz

create_clock -name {ad9866:ad9866_inst|dut1_pc[0]} -period 10.000 [get_registers {ad9866:ad9866_inst|dut1_pc[0]}]

derive_pll_clocks


create_generated_clock -source [get_ports {phy_clk}] -divide_by 4 -duty_cycle 50.00 -name phy_clk_div4 [get_keepers {phy_clk_div[1]}]

create_generated_clock -source [get_ports {phy_clk}] -divide_by 32 -duty_cycle 50.00 -name clk_ctrl [get_keepers {phy_clk_div[4]}]

derive_clock_uncertainty

set_clock_groups -asynchronous \
						-group { 	clk_76m8 }\
						-group {	phy_clk}\
						-group {	ad9866pll_inst|altpll_component|auto_generated|pll1|clk[0]} \
						-group {	ad9866pll_inst|altpll_component|auto_generated|pll1|clk[1]} \
						-group {	ad9866pll_inst|altpll_component|auto_generated|pll1|clk[2]} \
						-group {	ad9866pll_inst|altpll_component|auto_generated|pll1|clk[3]} \
						-group { 	ad9866:ad9866_inst|dut1_pc[0]}
					
				
# CLOCK						
#set_false_path -from {ad9866pll_inst|altpll_component|auto_generated|pll1|clk[3]}

## IO
set_false_path -to [get_ports {ptt_out} ]
set_false_path -from [get_ports {ptt_in} ]

## Ethernet module
#set_output_delay  -max  1.0 -clock phy_clk [get_ports {phy_tx[*]}]
#set_output_delay  -min -0.8 -clock phy_clk [get_ports {phy_tx[*]}]  -add_delay
#set_output_delay  -max  1.0 -clock phy_clk [get_ports {phy_tx[*]}]  -clock_fall -add_delay
#set_output_delay  -min -0.8 -clock phy_clk [get_ports {phy_tx[*]}]  -clock_fall -add_delay

#set_output_delay  -max  1.0 -clock phy_clk [get_ports {phy_tx_en}] 
#set_output_delay  -min -0.8 -clock phy_clk [get_ports {phy_tx_en}]  -add_delay
#set_output_delay  -max  1.0 -clock phy_clk [get_ports {phy_tx_en}]  -clock_fall -add_delay
#set_output_delay  -min -0.8 -clock phy_clk [get_ports {phy_tx_en}]  -clock_fall -add_delay

#set_input_delay  -max  0.6 -clock phy_clk [get_ports {phy_rx[*]}]
#set_input_delay  -min -1.0 -clock phy_clk -add_delay [get_ports {phy_rx[*]}]
#set_input_delay  -max  0.6 -clock phy_clk -clock_fall -add_delay [get_ports {phy_rx[*]}]
#set_input_delay  -min -1.0 -clock phy_clk -clock_fall -add_delay [get_ports {phy_rx[*]}]

#set_input_delay  -max  0.6 -clock phy_clk [get_ports {phy_rx_dv}]
#set_input_delay  -min -1.0 -clock phy_clk -add_delay [get_ports {phy_rx_dv}]
#set_input_delay  -max  0.6 -clock phy_clk -clock_fall -add_delay [get_ports {phy_rx_dv}]
#set_input_delay  -min -1.0 -clock phy_clk -clock_fall -add_delay [get_ports {phy_rx_dv}]


## Ethernet module
#PHY PHY_MDIO Data in +/- 10nS setup and hold
set_input_delay  10  -clock clk_ctrl -reference_pin [get_ports phy_mdc] {phy_mdio}
#PHY (2.5MHz)
set_output_delay  10 -clock clk_ctrl -reference_pin [get_ports phy_mdc] {phy_mdio}


## AD9866 RX Path
## See http://billauer.co.il/blog/2017/04/altera-intel-fpga-io-ff-packing/
set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 5.0 [get_ports {ad9866_rxsync}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.0 [get_ports {ad9866_rxsync}]

set_input_delay -add_delay -max -clock virt_ad9866_rxclk_rx 5.0 [get_ports {ad9866_rx[*]}]
set_input_delay -add_delay -min -clock virt_ad9866_rxclk_rx 0.0 [get_ports {ad9866_rx[*]}]


## AD9866 TX Path

set_output_delay -add_delay -max -clock virt_ad9866_rxclk_tx 2.5 [get_ports {ad9866_txsync}]
set_output_delay -add_delay -min -clock virt_ad9866_rxclk_tx 0.0 [get_ports {ad9866_txsync}]

set_output_delay -add_delay -max -clock virt_ad9866_rxclk_tx 2.5 [get_ports {ad9866_tx[*]}]
set_output_delay -add_delay -min -clock virt_ad9866_rxclk_tx 0.0 [get_ports {ad9866_tx[*]}]


## AD9866 Other IO
set_false_path -to [get_ports {ad9866_sclk}]
set_false_path -to [get_ports {ad9866_sdio}]
set_false_path -from [get_ports {ad9866_sdo}]
set_false_path -to [get_ports {ad9866_sen_n}]
set_false_path -to [get_ports {ad9866_rst_n}]
set_false_path -to [get_ports {ad9866_mode}]
set_false_path -to [get_ports {ad9866_txquietn}]


## Additional timing constraints
					
set_max_delay -from ad9866_tx[*]~reg0	-to ad9866_tx[*]	10	
set_max_delay -from ad9866_txsync~reg0	-to ad9866_txsync	10

#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_brp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_UDP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_brp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_ARP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_brp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_ICMP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_brp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_DHCP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_brp|dffe13a[*] -to	network:network_inst|tx_ready 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_bwp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_UDP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_bwp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_ARP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_bwp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_ICMP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_bwp|dffe13a[*] -to	network:network_inst|tx_protocol.PT_DHCP 7
#set_max_delay -from rx_iq_fifo:rx_iq_fifo_inst|dcfifo:dcfifo_component|dcfifo_jfn1:auto_generated|dffpipe_pe9:ws_bwp|dffe13a[*] -to	network:network_inst|tx_ready 7

#set_max_delay -from reset_handler:reset_handler_inst|reset~_Duplicate_1	-to network:network_inst|state[0] 7
#set_max_delay -from rmii_send:rmii_send_i|phy_tx_en	-to phy_tx_en 20
#set_max_delay -from rmii_recv:rmii_recv_i|phy_rx_d[*] -to phy_clk 5
#set_max_delay -from rmii_recv:rmii_recv_i|phy_rx_d -to phy_clk 5


					

#set_max_delay -from counter:counter_inst|lpm_counter:LPM_COUNTER_component|cntr_69j:auto_generated|counter_reg_bit[*]	-to counter:counter_inst|lpm_counter:LPM_COUNTER_component|cntr_69j:auto_generated|counter_reg_bit[*] 6			
#set_max_delay -from txFIFO:txFIFO_inst|dcfifo:dcfifo_component|dcfifo_tln1:auto_generated|dffpipe_re9:rs_brp|dffe12a[*]	-to spi_slave:spi_slave_rx2_inst|treg[*] 8
#set_max_delay -from txFIFO:txFIFO_inst|dcfifo:dcfifo_component|dcfifo_tln1:auto_generated|dffpipe_re9:rs_bwp|dffe12a[*]	-to spi_slave:spi_slave_rx2_inst|treg[*] 8
#set_max_delay -from txFIFO:txFIFO_EER_inst|dcfifo:dcfifo_component|dcfifo_tln1:auto_generated|dffpipe_re9:rs_bwp|dffe12a[*]	-to spi_slave:spi_slave_rx2_inst|treg[*] 8
#set_max_delay -from txFIFO:txFIFO_EER_inst|dcfifo:dcfifo_component|dcfifo_tln1:auto_generated|dffpipe_re9:rs_brp|dffe12a[*]	-to spi_slave:spi_slave_rx2_inst|treg[*] 8
	
## end of constraints