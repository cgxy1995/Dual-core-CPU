org 0x0000
ori $29,$0,0xFFC
jal ROUTINE
ori $1,$0,1
ori $2,$0,1
halt
ROUTINE:
ori $3,$0,3
ori $4,$0,3
ori $5,$0,4
sw $3, 100($0)
sw $4, 104($0)
sw $5, 108($0)
JR $31
