.data

# colors
red:            .word 0xff0000
green:          .word 0x00ff00
blue:           .word 0x0000ff

# constants
height:         .word 512
width:          .word 512
word_size:      .word 4

display:        .space 0x4000

.text

main_init:
	
	#li $t0, 0 #0
	#li $t1, 0 #0
	#li $t2, 42 
	#li $t3, 64 
	#la $t4, MongolWalk1
	addi $sp, $sp, -20
	#sw $t0, 0($sp)
	#sw $t1, 4($sp)
	#sw $t2, 8($sp)
	#sw $t3, 12($sp)
	#sw $t4, 16($sp)

main_waitLoop:
	
	# Wait for the player to press a key to begin the game
	jal sleep			
	nop
	lw $t0, 0xFFFF0000			# Retrieve transmitter control ready bit
	blez $t0, main_waitLoop		# Check if a key was pressed
	nop


main_draw:
	
	jal getPlayer
	nop
	or $t6, $zero, $v0	# Backup direction from keyboard


main_drawLeft:
	bne $t6, 0x01000000, main_drawRight
	nop
	b paladinWalk
	nop
	
	
main_drawRight:
	bne $t6, 0x02000000, main_exit
	nop
	b mongolWalk
	nop
	

main_exit:
	bne $t6, 0x03000000, main_draw
	nop
    li $v0, 10
    syscall

mongolWalk:
	li $t0, 700 
	li $t1, 310 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	
	
	li $t2, 42 
	li $t3, 64 
	la $t4, MongolWalk1
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	li $t2, 44 
	li $t3, 62 
	la $t4, MongolWalk2
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	li $t2, 43 
	li $t3, 62 
	la $t4, MongolWalk3
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	li $t2, 43 
	li $t3, 62 
	la $t4, MongolWalk4
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	j main_draw
	nop

paladinWalk:
	li $t0, -250 
	li $t1, 285 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	
	li $t2, 50 
	li $t3, 84 
	la $t4, PaladinWalk1
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	li $t2, 52 
	li $t3, 86 
	la $t4, PaladinWalk2
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	li $t2, 58 
	li $t3, 85 
	la $t4, PaladinWalk3
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	li $t2, 63 
	li $t3, 80 
	la $t4, PaladinWalk4
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	nop
	
	j main_draw
	nop


#
#  Parameters:
#    $a0 --> x coordinate
#    $a1 --> y coordinate
#    $a2 --> color hex code
#
drawPixel:

  # get size of a row
  lw $t0, word_size
  lw $t1, width
  multu $t0, $t1
  mflo $t1

  # column offset
  mult $a0, $t0
  mflo $t2

  # row offset
  mult $a1, $t1 #y*width
  mflo $t3

  # total offset
  add $t2, $t2, $t3

  # draw
  sw $a2, display($t2)

  jr $ra # return

#
#  Parameters:
#    0($sp) --> x coordinate
#    4($sp) --> y coordinate
#    8($sp) --> width
#    12($sp) --> height
#    16($sp) --> color hex code
#
drawFilledRectangle:

  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)

  lw $a2, 16($sp)

  dfr_row:
    # at the end of this row?
    bltz $s2, dfr_return
    lw $s3, 12($sp)
    add $a0, $s0, $s2 # x coordinate

    dfr_column:
      # at the end of this column?
      bltz $s3, dfr_end_row
      add $a1, $s1, $s3 # y coordinate

      jal drawPixel

      addi $s3, $s3, -1
      j dfr_column

  dfr_end_row:
    addi $s2, $s2, -1
    j dfr_row

  dfr_return:
    jr $ra # return


#
#  Parameters:
#    0($sp) --> x coordinate
#    4($sp) --> y coordinate
#    8($sp) --> width
#   12($sp) --> height
#   16($sp) --> address of bitmap pixel colors
#
drawBitmap:

  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $s3, 12($sp)
  lw $s4, 16($sp)

  # x counter
  li $s5, 0

  # jal paints over $ra
  move $s7, $ra

  db_row:
    # at the end of this row?
    beq $s2, $s5 db_return

    # y counter
    li $s6, 0

    lw $s3, 12($sp)
    add $a0, $s0, $s5 # x coordinate

    db_column:
      # at the end of this column?
      beq $s3, $s6, db_end_row
      add $a1, $s1, $s6 # y coordinate

      lw $a2, 0($s4) # load color

      jal drawPixel

      addi $s4, $s4, 4 # increment color address

      addi $s6, $s6, 1
      j db_column

  db_end_row:
    addi $s5, $s5, 1
    j db_row

  db_return:
    jr $s7 # return


#
#  Parameters:
#    none
#
sleep:
	ori $v0, $zero, 32		# Syscall sleep
	ori $a0, $zero, 60		# For this many miliseconds
	syscall
	jr $ra				# Return
	nop

#
#  Parameters:
#    none
#  Returns:
#	 v0 = player(side) OR exit program
#
getPlayer:
	lw $t0, 0xFFFF0004		# Load input value

getPlayer_left:
	bne $t0, 102, getPlayer_right
	nop
	ori $v0, $zero, 0x01000000	# left
	j getPlayer_done
	nop
getPlayer_right:
	bne $t0, 106, getPlayer_exit
	nop
	ori $v0, $zero, 0x02000000	# right
	j getPlayer_done
	nop
getPlayer_exit:
	bne $t0, 120, getPlayer_none
	nop
	ori $v0, $zero, 0x03000000	# exit
	j getPlayer_done
	nop
getPlayer_none:
						# Do nothing
getPlayer_done:
	jr $ra				# Return
	nop	