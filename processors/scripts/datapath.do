onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /datapath_tb/CLK
add wave -noupdate /datapath_tb/nRST
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/regfile/data
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/rfif/WEN
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/rfif/wsel
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/rfif/rsel1
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/rfif/rsel2
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/rfif/wdat
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/rfif/rdat1
add wave -noupdate -expand -group {reg file} /datapath_tb/DP_DUT/rfif/rdat2
add wave -noupdate -expand -group {hazard unit} /datapath_tb/DP_DUT/chaif/ihit
add wave -noupdate -expand -group {hazard unit} /datapath_tb/DP_DUT/chaif/dhit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {274 ns}
