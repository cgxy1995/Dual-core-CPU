org 0x00
	ori $sp , $zero , 0xfffc
	ori $t0 , $zero , 0x1234	# seed
	push $t0
	j main1

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


#----------------------------------------------------------------------
main1:
	#push $ra

  # lock m[crcarr+5] at first
  ori $t8 , $zero , 0x18
  addiu $a0 , $zero , crcarr
  jal lock



  #Init
  ori $t1 , $zero , 0
  ori $t3 , $zero , 0x30  # const dec(40) max lcv
  ori $t6 , $zero , 0x18  # const t6 = dec(6*4)

  ori $t8 , $zero , 0
  ori $t2 , $zero , 25

mainLoop:
  addiu $t8 , $t8 , 0x01
  beq $t8 , $t2 , fin

innerLoop:#for(t1=0;t1<(t3=40);t1+=4)

	# if lcv(t1)=5 then switch lock
	bne $t1 , $t6 , notLock5
	ori $a0 , $t6 , crcarr
	jal lock
	ori $a0 , $zero , crcarr
	jal unlock

notLock5:
	ori $a0 , $v0 , 0x00
	jal crc32
	


	addiu $t1 , $t1 , 0x4
	sw $v0 , $t1 , crcarr

	bne $t1 , $t3 , mainLoop

	# if counter 
	ori $t1 , $zero , 0x00
	# if lcv(t1)=0 then lock
	ori $a0 , $zero , crcarr
	jal lock
	ori $a0 , $t6 , crcarr
	jal unlock


	j mainLoop


fin:
	halt




 ### second processor-----------------------------------
 ### crcarr is the buffer-----------------------------------


  org   0x200                  # second processor p1
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  
  ori   $sp, $zero, 0x7ffc     # stack
  lui   $t1, 0x0               # initialize sum
  lui   $t2, 0x0               # initialize max
  ori   $t3, $zero, 0xFFFF     # initialize min
  lui   $t4, 0x0               # initialize total count
  lui   $t5, 0x0100            # 256 data

mainloop2:
  jal   mainp3                 # go to first half
  beq   $t4,$t5, findiv            
  jal   mainp2                 # go to first half 
  beq   $t4,$t5, findiv  
  j     mainloop2
done:
  halt   

# main function does something ugly but demonstrates beautifully
mainp2:
  push  $ra                   # save return address
  ori   $t7, $zero, 0x0018    # second buffer pos
  addiu  $a0, $t7, crcarr      # move lock to arguement register
  jal   lock                  # try to aquire the lock
  ori $t6, $a0, 0x0000
  # critical code segment
  lw    $t7, 4($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addi  $t4,$t4,1             # count one data
  lw    $t7, 8($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addiu  $t4,$t4,1             # count one data
  lw    $t7, 0xc($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addiu  $t4,$t4,1             # count one data
  lw    $t7, 0x10($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addiu  $t4,$t4,1             # count one data
  lw    $t7, 0x14($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addi  $t4,$t4,1             # count one data
  # critical code segment
  ori   $t7, $zero, 0x0018
  addiu  $a0, $t7, crcarr    # move lock to arguement register
  jal   unlock              # release the lock
  pop   $ra                 # get return address
  jr    $ra                 # return to caller

#mainloop3
mainp3:
  push  $ra                   # save return address
  addiu  $a0, $zero, crcarr    # move lock to arguement register
  jal   lock                  # try to aquire the lock
  ori $t6, $a0, 0x0000

  # critical code segment
  lw    $t7, 4($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addi  $t4,$t4,1             # count one data
  lw    $t7, 8($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addi  $t4,$t4,1             # count one data
  lw    $t7, 0xc($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addi  $t4,$t4,1             # count one data
  lw    $t7, 0x10($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addi  $t4,$t4,1             # count one data
  lw    $t7, 0x14($t6)
  addu $t1, $t1, $t7         # sum up the data
  jal   findmin
  jal   findmax
  addi  $t4,$t4,1             # count one data
  # critical code segment
  ori   $a0, $zero, crcarr  # move lock to arguement register
  jal   unlock              # release the lock
  pop   $ra                 # get return address
  jr    $ra                 # return to caller


findmin:
  push  $ra
  ori   $a0, $t7, 0x0000
  ori   $a1, $t3, 0x0000
  jal   min                   # find min
  ori   $t3, $v0, 0x0000
  pop   $ra
  jr    $ra

findmax:
  push  $ra
  ori   $a0, $t7, 0x0000
  ori   $a1, $t2, 0x0000
  jal   max                   # find max
  ori   $t2, $v0, 0x0000
  pop   $ra
  jr    $ra

findiv:
  ori $a1, $t5, 0x0000
  ori $a0, $t4, 0x0000
  jal divide

  j  done



res:
  cfw 0x0                   # end result should be 3



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
#------------------------------------------------------

#-max (a0=a,a1=b) returns v0=max(a,b)--------------
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



crcarr:
	cfw 0#lock2
	cfw 0xbadbad
	cfw 0xbadbad
	cfw 0xbadbad
	cfw 0xbadbad
	cfw 0xbadbad
	cfw 0#lock1
	cfw 0xbadbad
	cfw 0xbadbad
	cfw 0xbadbad
	cfw 0xbadbad
	cfw 0xbadbad

