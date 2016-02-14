org 0x0000
ori $5,$0,400
LOOP:
     lw $1, 0($0)
     addu $2, $2, $1
     lw $1,0($0)
     addu $2,$2,$1
     addiu $3, $3,8
     bne $3, $5,LOOP
halt
org   0x0080
cfw   0x0001
cfw   0x0002
cfw   0x0003
