
	addiu $2,$0,0x02
	addiu $3,$0,0x03
	addiu $4,$0,0x04

	
	addiu $1,$0,0x80
	sw $2 , $1 , 0x0
	addiu $1,$0,0xc0
	sw $3 , $1 , 0x0
	addiu $1,$0,0x40
	sw $4 , $1 , 0x0	# both dirty then write another one



	halt


	org 0x84
	cfw 0x8884


	org 0xc4
	cfw 0xccc4

	org 0x44
	cfw 0x4444


