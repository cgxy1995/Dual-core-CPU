onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dcache_tb/CLK
add wave -noupdate /dcache_tb/nRST
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemstore
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemload
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemaddr
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemWEN
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dmemREN
add wave -noupdate -expand -group dcif /dcache_tb/dcif/dhit
add wave -noupdate -expand -group ccif /dcache_tb/ccif/dwait
add wave -noupdate -expand -group ccif /dcache_tb/ccif/dstore
add wave -noupdate -expand -group ccif /dcache_tb/ccif/dload
add wave -noupdate -expand -group ccif /dcache_tb/ccif/daddr
add wave -noupdate -expand -group ccif /dcache_tb/ccif/dWEN
add wave -noupdate -expand -group ccif /dcache_tb/ccif/dREN
add wave -noupdate /dcache_tb/icdut/readValid1
add wave -noupdate /dcache_tb/icdut/readValid0
add wave -noupdate /dcache_tb/icdut/readTag1
add wave -noupdate /dcache_tb/icdut/readTag0
add wave -noupdate /dcache_tb/icdut/readRecentlyUsed1
add wave -noupdate /dcache_tb/icdut/readRecentlyUsed0
add wave -noupdate /dcache_tb/icdut/readDirty1
add wave -noupdate /dcache_tb/icdut/readDirty0
add wave -noupdate /dcache_tb/icdut/readData1
add wave -noupdate /dcache_tb/icdut/readData0
add wave -noupdate /dcache_tb/icdut/wsel
add wave -noupdate /dcache_tb/icdut/wen1
add wave -noupdate /dcache_tb/icdut/wen0
add wave -noupdate /dcache_tb/icdut/blkStat
add wave -noupdate -expand -group {w selects} /dcache_tb/icdut/wValid0
add wave -noupdate -expand -group {w selects} /dcache_tb/icdut/wValid1
add wave -noupdate -expand -group ccif.ram /dcache_tb/ccif/ramREN
add wave -noupdate -expand -group ccif.ram /dcache_tb/ccif/ramWEN
add wave -noupdate -expand -group ccif.ram /dcache_tb/ccif/ramaddr
add wave -noupdate -expand -group ccif.ram /dcache_tb/ccif/ramload
add wave -noupdate -expand -group ccif.ram /dcache_tb/ccif/ramstate
add wave -noupdate -expand -group ccif.ram /dcache_tb/ccif/ramstore
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20 ns} 0}
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
WaveRestoreZoom {0 ns} {264 ns}
