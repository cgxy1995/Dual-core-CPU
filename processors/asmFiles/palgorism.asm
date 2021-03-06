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


org 0x00
	jal init0

mainloop0:
	push $t1				# push total counter back to stack

	addiu $a0 , $t0 , locksec	# a0 = locksec
	push $t0
	jal lock		# lock buffer position
	pop $t0

	# perfor crc
	push $t0
	ori $a0 , $v0 , 0
	jal crc32
	pop $t0

	sw $v0 , $t0 , cirbuf	# save this crc into circular buffer

	addiu $a0 , $t0 , locksec 		# a0 = t0
	push $t0
	jal unlock
	pop $t0

	addiu $t0 , $t0 , 4		# circular buffer pointer increment
	ori $t5 , $zero , 40	# cricular buffer pointer max value
	bne $t0 , $t5 , noreset0	# if buffer pointer == 40
	ori $t0 , $zero ,0		# pointer = 0
noreset0:
	pop $t1					# get total counter
	addiu $t1 , $t1 , -1 	# total counter--
	bne $t1 , $zero , mainloop0	# if total counter == 0 halt program
	halt

#==================================================
# end of main loop for cpu0

init0:
	lw $v0 , $zero , seed
	ori $sp , $zero , 0x1000	# stack of cpu0 = 1000
	ori $t0 , $zero , 0			# t0 = buffer pointer
	lw $t1 , $zero , total
	jr $ra


#=================================================
org 0x200
	jal init1
mainloop1:
	push $t1	# get total counter

	addiu $a0 , $t0 , locksec	# a0 = locksec
	push $t0
	jal lock		# lock buffer position
	pop $t0

	lw $a0 , $t0 , cirbuf	# get crc value
	push $t0
	#min
	#or $a0 , $v0 , $zero	# compare $t6 to crc
	or $a1 , $t6 , $zero
	jal min
	or $t6 , $zero , $v0	# store min val back to $t6
	#max
	#or $a0 , $v0 , $zero	# compare $t7 to $v0
	or $a1 , $t7 , $zero
	jal max
	or $t7 , $zero , $v0	# store min val back to $t6
	#sum
	and $a0 , $a0 , $t3
	addu $t4 , $t4 , $a0	# sum += this crc val
	pop $t0

	sw $v0 , $t0 , cirbuf	# save this crc into circular buffer

	addiu $a0 , $t0 , locksec 		# a0 = t0
	jal unlock

	addiu $t0 , $t0 , 4		# circular buffer pointer increment
	ori $t5 , $zero , 40	# cricular buffer pointer max value
	bne $t0 , $t5 , noreset1	# if buffer pointer == 10
	ori $t0 , $zero , 0		# pointer = 0
noreset1:
	pop $t1					# get total counter
	addiu $t1 , $t1 , -1 	# total counter--
	bne $t1 , $zero , mainloop1	# if total counter == 0 halt program

	jal final




final:
	sw $t6 , $zero , maxresult
	sw $t7 , $zero , minresult
	srl $t4 , $t4 , 8
	sw $t4 , $zero , avgresult
	halt



# ++++++++++++++++++++++++
# end of cpu 1 main
init1:
	ori $t3 , $zero , 0xFFFF	# use this to clear 
	ori $t4 , $zero , 0 		# init crc sum
	ori $t6 , $zero , 0xFFFF	# t6 is min
	ori $t7 , $zero , 0x01		# t7 is max
	ori $sp , $zero , 0x2000	# stack of cpu0 = 1000
	ori $t0 , $zero , 0		# t0 = buffer pointer
	lw $t1 , $zero , total
	ori $t2 , $zero , 11 		# make cpu1 wait for 11 cycles to make sure
cpu1wait:
	addiu $t2 , $t2 , -1
	bne $t2 , $zero , cpu1wait
	jr $ra
####################


# end of program
#============================================
# functions::

# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
  ll    $t0, 0($a0)         # load lock location
  bne   $t0, $0, aquire     # wait on lock to be open
  addiu $t0, $t0, 1
  sc    $t0, 0($a0)
  beq   $t0, $0, lock       # if sc failed retry
  jr    $ra


# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock:
  sw    $0, 0($a0)
  jr    $ra



#crc32-----------------------------------------
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
#__________________________________________endcrc

#-max (a0=a,a1=b) returns v0=max(a,b)--------------
# registers a0-1,v0,t0
# a0 = a
# a1 = b
# v0 = result
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
#--------------------------------------------------

#-min (a0=a,a1=b) returns v0=min(a,b)--------------
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
#--------------------------------------------------


#-divide(N=$a0,D=$a1) returns (Q=$v0,R=$v1)--------
# registers a0-1,v0-1,t0
# a0 = Numerator
# a1 = Denominator
# v0 = Quotient
# v1 = Remainder
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



# data and lock
cirbuf:	# circular buffer
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd
	cfw 0xabcd

locksec:	# lock section
	cfw 0x0
	cfw 0x0
	cfw 0x0
	cfw 0x0
	cfw 0x0
	cfw 0x0
	cfw 0x0
	cfw 0x0
	cfw 0x0
	cfw 0x0

total:		# total number of crcs to calc
	cfw 256

seed:
	cfw 0x1


maxresult:
	cfw 0xaac
minresult:
	cfw 0xaac
avgresult:
	cfw 0xaac
