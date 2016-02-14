onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Control_unit_tb/PC_INIT
add wave -noupdate /Control_unit_tb/PERIOD
add wave -noupdate /Control_unit_tb/CLK
add wave -noupdate /Control_unit_tb/nRST
add wave -noupdate /Control_unit_tb/spec
add wave -noupdate /Control_unit_tb/opc
add wave -noupdate /Control_unit_tb/opcode
add wave -noupdate /Control_unit_tb/rs
add wave -noupdate /Control_unit_tb/rt
add wave -noupdate /Control_unit_tb/rd
add wave -noupdate /Control_unit_tb/sa
add wave -noupdate /Control_unit_tb/imm
add wave -noupdate /Control_unit_tb/JumpAddr
add wave -noupdate /Control_unit_tb/offset
add wave -noupdate /Control_unit_tb/rcode
add wave -noupdate /Control_unit_tb/immext
add wave -noupdate /Control_unit_tb/PC
add wave -noupdate /Control_unit_tb/PCtemp
add wave -noupdate /Control_unit_tb/PCnxt
add wave -noupdate /Control_unit_tb/PC4
add wave -noupdate /Control_unit_tb/PCelse
add wave -noupdate /Control_unit_tb/haltff
add wave -noupdate /Control_unit_tb/dmemstore
add wave -noupdate /Control_unit_tb/dmemload
add wave -noupdate /Control_unit_tb/dmemaddr
add wave -noupdate /Control_unit_tb/dhit
add wave -noupdate /Control_unit_tb/ihit
add wave -noupdate /Control_unit_tb/dfin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {882 ns} 0}
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
WaveRestoreZoom {755 ns} {1185 ns}
