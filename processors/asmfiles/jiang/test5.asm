org 0x0000
ori $2, $0, 20
lw $3, 100($2)
or $4, $0, $3
halt
org 120
cfw 0xDEAD
cfw 0xBEEF
