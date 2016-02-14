#REGISTERS
#at $1 at
#v $2-3 function returns
#a $4-7 function args
#t $8-15 temps
#s $16-23 saved temps (callee preserved)
#t $24-25 temps
#k $26-27 kernel
#gp $28 gp (callee preserved)
#sp $29 sp (callee preserved)
#fp $30 fp (callee preserved)
#ra $31 return address

org 0x0000
ori $27, $0, 1500 #lock location
ori $sp, $0, 0x3FFC
ori $a0, $0, 0x1 #seed = 1
ori $16, $0, 40 #comparason value 40 for beq
ori $17, $0, 250 # num of random numbers
ori $18, $0, 0 #buffer head pointer
randloop:
jal crc32 #generate rand number
sw $2,buffer($18) #save result to buffer
addiu $18, $18, 4 #increment buffer head
bne $18, $16, noreset #if head pointer=40, reset to 0
jal unlock #test unlock
ori $18, $0, 0 # reset head pointer to 0
noreset:
addiu $17, $17, -1
bne $17, $0, randloop

jal lock
getout:
ori $18, $0, 0 # reset head pointer to 0
ori $17, $0, 6 # num of random numbers
ori $16, $0, 24 #comparason value 24 for beq
randloop2:
jal crc32 #generate rand number
sw $2,buffer($18) #save result to buffer
addiu $18, $18, 4 #increment buffer head
bne $18, $16, noreset2 #if head pointer=24, reset to 0
jal unlock #test unlock
#ori $18, $0, 0 # reset head pointer to 0
noreset2:
addiu $17, $17, -1
bne $17, $0, randloop2
halt
################################################################
org 0x200 
ori $sp, $0, 0x3FFC
ori $27, $0, 1500 #lock location
ori $18, $0, 0 #buffer head pointer
ori $16, $0, 0 #store sum and quotient
ori $17, $0, 10 #size of buffer
ori $19, $0, 0 #test register
ori $21, $0, 40 #comparason value 40 for beq
ori $22, $0, 0 #max
ori $23, $0, 0 #min
ori $24, $0, 25 #big loop
bigloop:

jal lock #lock
loop:
lw $20, buffer($18) #load from buffer
or $25, $20, $0
andi $20, $20, 0xFFFF #take 16 least sig bits
addu $16, $20, $16 #add to reg 16 (accumulate)
addiu $18, $18, 4 #increment head pointer

or $a0, $0, $22 #max
or $a1, $0, $25 #
jal max   # find max
or $22, $v0, $0 #save max to R22

or $a0, $0, $23 #min
or $a1, $0, $25
jal min
or $23, $v0, $0 #save min to R23

bne $18, $21, loop #branch if not = 40

addiu $24, $24, -1
ori $18, $0, 0 #buffer head pointer
bne $24, $0, bigloop
jal unlock
	
getout2:
ori $21, $0, 24 #comparason value 24 for beq
jal lock
loop2:
lw $20, buffer($18) #load from buffer
or $25, $20, $0
andi $20, $20, 0xFFFF #take 16 least sig bits
addu $16, $20, $16 #add to reg 16 (accumulate)
addiu $18, $18, 4 #increment head pointer

or $a0, $0, $22 #max
or $a1, $0, $25 #
jal max   # find max
or $22, $v0, $0 #save max to R22

or $a0, $0, $23 #min
or $a1, $0, $25
jal min
or $23, $v0, $0 #save min to R23

bne $18, $21, loop2 #branch if not = 24

or $a0, $16, $0 #divident =$16
ori $a1, $0,256 #
jal divide #do division
or $15, $2, $0 #save quotient to $15
halt
max:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a0, $a1
  beq   $t0, $0, maxrtn
  or    $v0, $0, $a1
maxrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra
min:
  push  $ra
  push  $a0
  push  $a1
  or    $v0, $0, $a0
  slt   $t0, $a1, $a0
  beq   $t0, $0, minrtn
  or    $v0, $0, $a1
minrtn:
  pop   $a1
  pop   $a0
  pop   $ra
  jr    $ra


# registers a0-1,v0-1,t0
# a0 = Numerator
# a1 = Denominator
# v0 = Quotient
# v1 = Remainder

#-divide(N=$a0,D=$a1) returns (Q=$v0,R=$v1)--------
divide:               # setup frame
  push  $ra           # saved return address
  push  $a0           # saved register
  push  $a1           # saved register
  or    $v0, $0, $0   # Quotient v0=0
  or    $v1, $0, $a0  # Remainder t2=N=a0
  beq   $0, $a1, divrtn # test zero D
  slt   $t0, $a1, $0  # test neg D
  bne   $t0, $0, divdneg
  slt   $t0, $a0, $0  # test neg N
  bne   $t0, $0, divnneg
divloop:
  slt   $t0, $v1, $a1 # while R >= D
  #slt $t0, $0, $a1
  bne   $t0, $0, divrtn
  addiu $v0, $v0, 1   # Q = Q + 1
  subu  $v1, $v1, $a1 # R = R - D
  j     divloop
divnneg:
  subu  $a0, $0, $a0  # negate N
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
  beq   $v1, $0, divrtn
  addiu $v0, $v0, -1  # return -Q-1
  j     divrtn
divdneg:
  subu  $a0, $0, $a1  # negate D
  jal   divide        # call divide
  subu  $v0, $0, $v0  # negate Q
divrtn:
  pop $a1
  pop $a0
  pop $ra
  jr  $ra
#-divide--------------------------------------------

# USAGE random0 = crc(seed), random1 = crc(random0)
#       randomN = crc(randomN-1)
#------------------------------------------------------
# $v0 = crc32($a0)
crc32:
  lui $t1, 0x04C1
  ori $t1, $t1, 0x1DB7
  or $t2, $0, $0
  ori $t3, $0, 32

l1:
  slt $t4, $t2, $t3
  beq $t4, $zero, l2

  srl $t4, $a0, 31
  sll $a0, $a0, 1
  beq $t4, $0, l3
  xor $a0, $a0, $t1
l3:
  addiu $t2, $t2, 1
  j l1
l2:
  or $v0, $a0, $0
  jr $ra
#------------------------------------------------------
lock:
aquire:
  ll    $t0, 0($27)         # load lock location
  bne   $t0, $0, aquire     # wait on lock to be open
  addiu $t0, $t0, 1
  sc    $t0, 0($27)
  beq   $t0, $0, lock       # if sc failed retry
  jr    $ra


# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock:
  sw    $0, 0($27)
  jr    $ra

buffer:

org 1500
cfw 1


