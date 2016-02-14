onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/CLK
add wave -noupdate -expand -group ram /system_tb/DUT/RAM/ramif/ramREN
add wave -noupdate -expand -group ram /system_tb/DUT/RAM/ramif/ramWEN
add wave -noupdate -expand -group ram /system_tb/DUT/RAM/ramif/ramaddr
add wave -noupdate -expand -group ram /system_tb/DUT/RAM/ramif/ramstore
add wave -noupdate -expand -group ram /system_tb/DUT/RAM/ramif/ramload
add wave -noupdate -expand -group ram /system_tb/DUT/RAM/ramif/ramstate
add wave -noupdate -expand -group ram /system_tb/DUT/RAM/count
add wave -noupdate -expand -group ccif.ii -radix binary /system_tb/DUT/CPU/ccif/iREN
add wave -noupdate -expand -group ccif.ii /system_tb/DUT/CPU/ccif/iaddr
add wave -noupdate -expand -group ccif.ii /system_tb/DUT/CPU/ccif/iload
add wave -noupdate -expand -group ccif.ii -radix binary /system_tb/DUT/CPU/ccif/iwait
add wave -noupdate -expand -group ccif.dd -radix binary /system_tb/DUT/CPU/ccif/dREN
add wave -noupdate -expand -group ccif.dd -radix binary /system_tb/DUT/CPU/ccif/dWEN
add wave -noupdate -expand -group ccif.dd -expand /system_tb/DUT/CPU/ccif/daddr
add wave -noupdate -expand -group ccif.dd /system_tb/DUT/CPU/ccif/dload
add wave -noupdate -expand -group ccif.dd /system_tb/DUT/CPU/ccif/dstore
add wave -noupdate -expand -group ccif.dd -radix binary /system_tb/DUT/CPU/ccif/dwait
add wave -noupdate -expand -group ccif.cc /system_tb/DUT/CPU/ccif/ccdirty
add wave -noupdate -expand -group ccif.cc /system_tb/DUT/CPU/ccif/ccinv
add wave -noupdate -expand -group ccif.cc -expand /system_tb/DUT/CPU/ccif/ccsnoopaddr
add wave -noupdate -expand -group ccif.cc /system_tb/DUT/CPU/ccif/cctrans
add wave -noupdate -expand -group ccif.cc /system_tb/DUT/CPU/ccif/ccwait
add wave -noupdate -expand -group ccif.cc /system_tb/DUT/CPU/ccif/ccwrite
add wave -noupdate /system_tb/DUT/CPU/CC/cstate
add wave -noupdate -expand -group cpu0.iload /system_tb/DUT/CPU/DP0/back/imemload_IFID
add wave -noupdate -expand -group cpu0.iload /system_tb/DUT/CPU/DP0/back/imemload_IDEX
add wave -noupdate -expand -group cpu0.iload /system_tb/DUT/CPU/DP0/back/imemload_EXME
add wave -noupdate -expand -group cpu0.iload /system_tb/DUT/CPU/DP0/back/imemload_MEWB
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/dmemREN
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/dmemWEN
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/dmemaddr
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/dmemload
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/dmemstore
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/dhit
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/ihit
add wave -noupdate -expand -group cpu0.dcif /system_tb/DUT/CPU/dcif0/datomic
add wave -noupdate -expand -group cpu1.iload /system_tb/DUT/CPU/DP1/back/imemload_IFID
add wave -noupdate -expand -group cpu1.iload /system_tb/DUT/CPU/DP1/back/imemload_IDEX
add wave -noupdate -expand -group cpu1.iload /system_tb/DUT/CPU/DP1/back/imemload_EXME
add wave -noupdate -expand -group cpu1.iload /system_tb/DUT/CPU/DP1/back/imemload_MEWB
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/dmemREN
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/dmemWEN
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/dmemaddr
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/dmemload
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/dmemstore
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/dhit
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/ihit
add wave -noupdate -expand -group cpu1.dcif /system_tb/DUT/CPU/dcif1/datomic
add wave -noupdate -group cpu0.set0 /system_tb/DUT/CPU/CM0/DCACHE/readValid0
add wave -noupdate -group cpu0.set0 /system_tb/DUT/CPU/CM0/DCACHE/readValid1
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[0]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[0]/oneBlock/rData1}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[1]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[1]/oneBlock/rData1}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[2]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[2]/oneBlock/rData1}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[3]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[3]/oneBlock/rData1}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[4]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[4]/oneBlock/rData1}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[5]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[5]/oneBlock/rData1}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[6]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[6]/oneBlock/rData1}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[7]/oneBlock/rData0}
add wave -noupdate -group cpu0.set0 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[7]/oneBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[0]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[0]/twoBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[1]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[1]/twoBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[2]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[2]/twoBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[3]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[3]/twoBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[4]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[4]/twoBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[5]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[5]/twoBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[6]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[6]/twoBlock/rData1}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[7]/twoBlock/rData0}
add wave -noupdate -group cpu0.set1 {/system_tb/DUT/CPU/CM0/DCACHE/block_gen[7]/twoBlock/rData1}
add wave -noupdate -group cpu1.set0 /system_tb/DUT/CPU/CM1/DCACHE/readValid0
add wave -noupdate -group cpu1.set0 /system_tb/DUT/CPU/CM1/DCACHE/readValid1
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[0]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[0]/oneBlock/rData1}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[1]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[1]/oneBlock/rData1}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[2]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[2]/oneBlock/rData1}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[3]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[3]/oneBlock/rData1}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[4]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[4]/oneBlock/rData1}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[5]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[5]/oneBlock/rData1}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[6]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[6]/oneBlock/rData1}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[7]/oneBlock/rData0}
add wave -noupdate -group cpu1.set0 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[7]/oneBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[0]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[0]/twoBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[1]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[1]/twoBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[2]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[2]/twoBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[3]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[3]/twoBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[4]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[4]/twoBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[5]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[5]/twoBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[6]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[6]/twoBlock/rData1}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[7]/twoBlock/rData0}
add wave -noupdate -group cpu1.set1 {/system_tb/DUT/CPU/CM1/DCACHE/block_gen[7]/twoBlock/rData1}
add wave -noupdate /system_tb/DUT/CPU/CM0/DCACHE/rmwstate
add wave -noupdate /system_tb/DUT/CPU/CM0/DCACHE/rmwval
add wave -noupdate /system_tb/DUT/CPU/CM1/DCACHE/rmwstate
add wave -noupdate /system_tb/DUT/CPU/CM1/DCACHE/rmwval
add wave -noupdate -radix unsigned /system_tb/DUT/CPU/CM1/DCACHE/mainCase
add wave -noupdate -radix unsigned /system_tb/DUT/CPU/DP0/whatIsGlueLogic
add wave -noupdate /system_tb/DUT/CPU/DP0/back/dmemstore_IMAGINARY_EXME
add wave -noupdate /system_tb/DUT/CPU/DP0/back/dmemstore_IMAGINARY_IDEX
add wave -noupdate /system_tb/DUT/CPU/DP0/back/dmemstore_EARLY_EXME
add wave -noupdate /system_tb/DUT/CPU/DP0/back/dmemstore_EARLY_IDEX
add wave -noupdate /system_tb/DUT/CPU/DP0/rt_IDEX
add wave -noupdate /system_tb/DUT/CPU/DP0/back/wsel_MEWB
add wave -noupdate /system_tb/DUT/CPU/DP0/back/cu_rWEN_MEWB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {2772370 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 258
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
WaveRestoreZoom {2431516 ps} {3087766 ps}
bookmark add wave bookmark0 {{603568 ps} {1128568 ps}} 30
bookmark add wave bookmark1 {{673163 ps} {759297 ps}} 3
bookmark add wave bookmark2 {{1582402 ps} {1648028 ps}} 43
bookmark add wave bookmark3 {{2175401 ps} {2831651 ps}} 30
