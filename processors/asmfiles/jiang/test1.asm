org 0x0000
ori $1,$0, 100
ori $2,$0, 104
lw $3, 100($0)
lw $4, 0($2)
nop
nop
sw $3, 12($1)
sw $4, 16($1)
halt

org 100
cfw 0x1234
cfw 0x2345
cfw 0x3456
