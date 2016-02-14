ori $1,$0,100
ori $2,$0,104

lw $3,100($0)
lw $4,0($2)
bne $3,$4,tag
halt



tag:
sw $3,$0,0xf0
sw $4,$0,0xf4
halt

org 100
cfw 0xabcd

