org 0x0000
ori $29,$0,0xFFC
ori $1, $0, 0x0500
push $1
ori $1, $0, 0x0400
push $1
#routine begins
pop $8
pop $9
push $10
MUL: 
     andi $10, $9, 1
     beq $10, $0, SHIFT
     addu $12, $8, $12
SHIFT:
     sll $8, $8, 1
     srl $9, $9, 1
     bne $9, $0, MUL
pop $10
push $12
halt
