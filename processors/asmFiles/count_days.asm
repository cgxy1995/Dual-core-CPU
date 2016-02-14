org 0x0000
ori $29,$0,0xFFC
ori $1, $0, 3 #current day
ori $2, $0, 9 #current month
ori $3, $0, 2013 #current year

addiu $3, $3, -2000
addiu $2, $2, -1
ori $4, $0, 365
push $4
push $3
jal ROUTINE
ori $4, $0, 30
push $4
push $2
jal ROUTINE
pop $2
pop $3
addu $1, $1, $2
addu $1, $1 ,$3
J DONE
ROUTINE:
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
addu $12, $0, $0
JR $31
DONE:
     halt
org 0x200
     halt
