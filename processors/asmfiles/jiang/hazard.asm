org 0x0000
ori $3, $0, 10
ori $7, $0, 0x001e
addu $4, $3, $3
addu $5, $3, $4
addu $6, $5, $4
beq $7, $5, jump
ori $1,$0, 9
ori $1,$0, 8
jump:
ori $2, $0, 4
ori $2, $0, 5
halt
