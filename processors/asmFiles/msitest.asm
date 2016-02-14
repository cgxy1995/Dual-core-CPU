org 0x00
lw $1 , $0 , 0x1000
lui $2 , 0xcccc
or $3 , $2 , $1
sw $3 , $0 , 0x1000
nop
nop
nop
nop	# wait for cpu1 to lw<-0x1000
nop
nop
halt


org 0x200
lw $1 , $0 , 0x1000
lw $2 , $0 , 0x1004
nop
nop
nop
nop	# wait for cpu0 to sw->0x1000
nop
nop
lw $1, $0 , 0x1000
lw $3 , $0 , 0x1008
lw $4 , $0 , 0x100c
lw $5 , $0 , 0x1010
lw $6 , $0 , 0x1014

sw $1 , $0 , 0x1004
sw $2 , $0 , 0x1008
sw $3 , $0 , 0x100c
sw $4 , $0 , 0x1000
sw $5 , $0 , 0x1014
sw $6 , $0 , 0x1018
halt






org 0x1000
cfw 0x1000	#1000
cfw 0x1004	#1004
cfw 0x1008	#1008
cfw 0x100c	#100c
cfw 0x1010	#1010
cfw 0x1014	#1014
