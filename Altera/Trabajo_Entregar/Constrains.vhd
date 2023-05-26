    ## Clock signal
    set_property PACKAGE_PIN W5 [get_ports clk]							
        set_property IOSTANDARD LVCMOS33 [get_ports clk]
        create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


    ### Switches
    set_property PACKAGE_PIN V17 [get_ports {pwmEnt[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {pwmEnt[0]}]
    set_property PACKAGE_PIN V16 [get_ports {pwmEnt[1]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {pwmEnt[1]}]
    set_property PACKAGE_PIN W16 [get_ports {pwmEnt[2]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {pwmEnt[2]}]
    set_property PACKAGE_PIN W17 [get_ports {pwmEnt[3]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {pwmEnt[3]}]
    set_property PACKAGE_PIN V15 [get_ports {sw[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
    set_property PACKAGE_PIN W14 [get_ports {sw[1]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
    set_property PACKAGE_PIN W13 [get_ports {sw[2]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
    set_property PACKAGE_PIN V2 [get_ports {sw[3]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
    set_property PACKAGE_PIN T2 [get_ports {modo_funcionamiento[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {modo_funcionamiento[0]}]
    set_property PACKAGE_PIN R3 [get_ports {modo_funcionamiento[1]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {modo_funcionamiento[1]}]
    set_property PACKAGE_PIN U1 [get_ports {parada}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {parada}]
    set_property PACKAGE_PIN T1 [get_ports {sw_stepper}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {sw_stepper}]
    set_property PACKAGE_PIN R2 [get_ports {sw_blq_stepper}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {sw_blq_stepper}]
     

    ## LEDs
    set_property PACKAGE_PIN U16 [get_ports {led[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
    set_property PACKAGE_PIN E19 [get_ports {led[1]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
    set_property PACKAGE_PIN U19 [get_ports {led[2]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
    set_property PACKAGE_PIN V19 [get_ports {led[3]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
    set_property PACKAGE_PIN W18 [get_ports {led[4]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
    set_property PACKAGE_PIN U15 [get_ports {led[5]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
    set_property PACKAGE_PIN U14 [get_ports {led[6]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
    set_property PACKAGE_PIN V14 [get_ports {led[7]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]
    set_property PACKAGE_PIN V13 [get_ports {led[8]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]
    set_property PACKAGE_PIN V3 [get_ports {led[9]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]
    set_property PACKAGE_PIN W3 [get_ports {led[10]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]
    set_property PACKAGE_PIN U3 [get_ports {led[11]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]
    set_property PACKAGE_PIN P3 [get_ports {led[12]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]
    set_property PACKAGE_PIN N3 [get_ports {led[13]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]
    set_property PACKAGE_PIN P1 [get_ports {led[14]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[14]}]
    set_property PACKAGE_PIN L1 [get_ports {led[15]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]
        
        
    ##7 segment display
    set_property PACKAGE_PIN W7 [get_ports {7_seg[6]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {7_seg[6]}]
    set_property PACKAGE_PIN W6 [get_ports {7_seg[5]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {7_seg[5]}]
    set_property PACKAGE_PIN U8 [get_ports {7_seg[4]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {7_seg[4]}]
    set_property PACKAGE_PIN V8 [get_ports {7_seg[3]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {7_seg[3]}]
    set_property PACKAGE_PIN U5 [get_ports {7_seg[2]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {7_seg[2]}]
    set_property PACKAGE_PIN V5 [get_ports {7_seg[1]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {7_seg[1]}]
    set_property PACKAGE_PIN U7 [get_ports {7_seg[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {7_seg[0]}]


    ##Pmod Header JB
    ##Sch name = JB3
    set_property PACKAGE_PIN B15 [get_ports {DIR}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {DIR}]
    ##Sch name = JB8
    set_property PACKAGE_PIN A17 [get_ports {STEP}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {STEP}]
    ##Sch name = JB9
    set_property PACKAGE_PIN C15 [get_ports {en_stepper}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {en_stepper}]
        

    ##Pmod Header JC
    ##Sch name = JC1
    set_property PACKAGE_PIN K17 [get_ports {motor_DC_On[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {motor_DC_On[0]}]
    ##Sch name = JC2
    set_property PACKAGE_PIN M18 [get_ports {ECHO}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {ECHO}]
    ##Sch name = JC3
    set_property PACKAGE_PIN N17 [get_ports {FC1_Cale}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {FC1_Cale}]
    ##Sch name = JC7
    set_property PACKAGE_PIN L17 [get_ports {motor_DC_OnEnc[1]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {motor_DC_On[1]}]
    ##Sch name = JC8
    set_property PACKAGE_PIN M19 [get_ports {TRIGGER}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {TRIGGER}]
    ##Sch name = JC9
    set_property PACKAGE_PIN P17 [get_ports {FC2_Tarj}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {FC2_Tarj}]
    ##Sch name = JC10
    set_property PACKAGE_PIN R18 [get_ports {ds_data_bus}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {ds_data_bus}]
    set_property PACKAGE_PIN U2 [get_ports {enable_seg[0]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {enable_seg[0]}]
    set_property PACKAGE_PIN U4 [get_ports {enable_seg[1]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {enable_seg[1]}]
    set_property PACKAGE_PIN V4 [get_ports {enable_seg[2]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {enable_seg[2]}]
    set_property PACKAGE_PIN W4 [get_ports {enable_seg[3]}]					
        set_property IOSTANDARD LVCMOS33 [get_ports {enable_seg[3]}]
    
    
    ###Buttons
    set_property PACKAGE_PIN U18 [get_ports inicio]						
        set_property IOSTANDARD LVCMOS33 [get_ports inicio]
    set_property PACKAGE_PIN T18 [get_ports boton_U]						
        set_property IOSTANDARD LVCMOS33 [get_ports boton_U]
    set_property PACKAGE_PIN W19 [get_ports boton_L]						
        set_property IOSTANDARD LVCMOS33 [get_ports boton_L]
    set_property PACKAGE_PIN T17 [get_ports boton_R]						
        set_property IOSTANDARD LVCMOS33 [get_ports boton_R]
    set_property PACKAGE_PIN U17 [get_ports boton_D]						
        set_property IOSTANDARD LVCMOS33 [get_ports boton_D]