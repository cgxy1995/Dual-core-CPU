onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /memory_control_tb/CLK
add wave -noupdate -radix binary /memory_control_tb/nRST
add wave -noupdate -radix binary /memory_control_tb/ccif/ccdirty
add wave -noupdate -radix binary /memory_control_tb/ccif/ccinv
add wave -noupdate /memory_control_tb/ccif/ccsnoopaddr
add wave -noupdate -radix binary /memory_control_tb/ccif/cctrans
add wave -noupdate -radix binary /memory_control_tb/ccif/ccwait
add wave -noupdate -radix binary /memory_control_tb/ccif/ccwrite
add wave -noupdate -radix binary /memory_control_tb/ccif/dREN
add wave -noupdate -radix binary /memory_control_tb/ccif/dWEN
add wave -noupdate /memory_control_tb/ccif/daddr
add wave -noupdate /memory_control_tb/ccif/dload
add wave -noupdate /memory_control_tb/ccif/dstore
add wave -noupdate -radix binary /memory_control_tb/ccif/dwait
add wave -noupdate -radix binary /memory_control_tb/ccif/iREN
add wave -noupdate /memory_control_tb/ccif/iaddr
add wave -noupdate /memory_control_tb/ccif/iload
add wave -noupdate -radix binary /memory_control_tb/ccif/iwait
add wave -noupdate -radix binary /memory_control_tb/ccif/localwrit
add wave -noupdate -radix binary /memory_control_tb/ccif/ramREN
add wave -noupdate -radix binary /memory_control_tb/ccif/ramWEN
add wave -noupdate /memory_control_tb/ccif/ramaddr
add wave -noupdate /memory_control_tb/ccif/ramload
add wave -noupdate -radix binary /memory_control_tb/ccif/ramstate
add wave -noupdate /memory_control_tb/ccif/ramstore
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {32 ns} 0}
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
WaveRestoreZoom {0 ns} {198 ns}
bookmark add wave bookmark0 {{603568 ps} {1128568 ps}} 30
bookmark add wave bookmark1 {{673163 ps} {759297 ps}} 3
bookmark add wave bookmark2 {{1582402 ps} {1648028 ps}} 43
