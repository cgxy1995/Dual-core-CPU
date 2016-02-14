
  #------------------------------------------------------------------
  # R-type Instruction (ALU) Test Program
  #------------------------------------------------------------------

  org 0x0000
  ori   $1,$zero,0xD269
  ori   $2,$zero,0x37F1

  ori   $21,$zero,0x80
  ori   $22,$zero,0xF0

# Now running all R type instructions
  or    $3,$1,$2
  and   $4,$1,$2
  andi  $5,$1,0xF
  addu  $6,$1,$2
  addiu $7,$3,0x8740
  subu  $8,$4,$2
  xor   $9,$5,$2
  xori  $10,$1,0xf33f
  sll   $11,$1,4
  srl   $12,$1,5
  nor   $13,$1,$2
  addiu $14,0xface($0)
  addiu $15,0xdead($0)
  
  addiu $12,$0,0x100
  addiu $1,$0,-4


  jal    jallabel

jrback:
bnesrt:
  addu  $12,$1,$12
  sw    $14,0x1000($12)
  bne   $12,$0,bnesrt

  addiu $5,$0,0x200
  addiu $1,$0,-4
jlabel:
  beq   $5,$0,beqend
  addu  $5,$1,$5
  sw    $15,0x2000($5)
  j     jlabel

beqend:
  
  addu $1,$2,$2
  addu $1,$2,$2
  addu $1,$2,$2
  addu $1,$2,$2
  addu $1,$2,$2
  addu $1,$2,$2
  addu $1,$2,$2

  j     programend
jallabel:
  jr  $31

programend:
 #Store them to verify the results
 sw    $13,0($22)
 sw    $3,0($21)
 sw    $4,4($21)
 sw    $5,8($21)
 sw    $6,12($21)
 sw    $7,16($21)
 sw    $8,20($21)
  sw    $9,24($21)
  sw    $10,28($21)
  sw    $11,32($21)
  sw    $12,36($21)
  halt  # that's all
