ori $1,$0,10
lui $1,0xdead
lui $2,0xdead

beq $1,$2,onetag
ori $3,$0,5
onetag:
ori $4,$0,10
sw $3,$0,0xf0
sw $4,$0,0xf4





halt

org 100
cfw 0xabcd

