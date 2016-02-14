org 0x00	#CPU 0
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
# Store them to verify the results
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



org 0x200	#CPU 1  nor   $13,$1,$2
  srl   $12,$1,5
  sll   $11,$1,4
  xori  $10,$1,0xf33f
  xor   $9,$5,$2
  subu  $8,$4,$2
  addiu $7,$3,0x8740
  addu  $6,$1,$2
  andi  $5,$1,0xF
  and   $4,$1,$2
  or    $3,$1,$2
# Now running all R type instructions

  ori   $22,$zero,0xF0
  ori   $21,$zero,0x80

  ori   $2,$zero,0x37F1
  ori   $1,$zero,0xD269
# Store them to verify the results
  sw    $13,1000($22)
  sw    $3,1000($21)
  sw    $4,1044($21)
  sw    $5,1088($21)
  sw    $6,1012($21)
  sw    $7,1016($21)
  sw    $8,1020($21)
  sw    $9,1024($21)
  sw    $10,1028($21)
  sw    $11,1032($21)
  sw    $12,1036($21)
  halt  # that's all
