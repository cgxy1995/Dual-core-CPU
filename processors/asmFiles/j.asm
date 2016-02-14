org 0x0000
j one
j two



one:
ori $2,$0,0x1111
sw $2,$0,0x100
halt


two:
halt
