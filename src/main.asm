.data

# constants
height:         .word 512
width:          .word 512
word_size:      .word 4
hot_pink:       .word 0xff0080
clear:					.word 0X000000

display:        .space 0x4000
data_pointer:   .word 0x103df050
data:           .word 0x103df050
new_line:       .ascii "\n"


.text

#  
# Desc:
#		Display main menu
# Parameters:
# 	none
# Returns:
#		none
#
main_menu:	
									
	addi $sp, $sp, -20
	
	li $t0, 75																			# x position 
	li $t1, -175																		# y position
	li $t2, 327 																		# width
	li $t3, 95 																			# height
	la $t4, Battleforts															# bitmap label
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap


#
# Desc:
#		Check user input for main menu
# Parameters:
#		none
# Returns:
#		none
#
main_menu_userInput:
												                					# Wait for user to press a key
	lw $t0, 0xFFFF0000															# Retrieve transmitter control ready bit
	blez $t0, main_menu_userInput										# Check if a key was pressed
											
	jal getInput																		# Read keyboard input
  or $t6, $zero, $v0															# Backup direction from keyboard
	beq $t6, 0x04000000, main_exit									# Exit if user pressed 'x'
	bne $t6, 0x01000000, main_menu_userInput				# Play if user pressed 'p'
																									# Otherwise, loop until valid key is pressed	


# 
# Desc: 
#		Clear main menu
# Parameters:
#		none
# Returns:
#		none
# 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 
main_clearMenu: 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 		
									
	li $t0, 75																			# x position
	li $t1, -175																		# y position
	li $t2, 327 																		# width
	li $t3, 95 																			# height
	la $t4, clear																		# bitmap label
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap	


#
# Desc: 
#		Display instruction menu	
# Parameters:
#		none
# Returns:
#		none
#
main_instructions:

	li $t0, 40																		  # x position
	li $t1, -175																		# y position
	li $t2, 393 																		# width
	li $t3, 104 																		# height
	la $t4, Instructions 														# bitmap label
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap


#
# Desc:
# 	Check user input for instruction menu
# Parameters:
#		none
# Returns:
#		none
#
main_instructions_userInput:												
  																								# Wait for user to press a key
	lw $t0, 0xFFFF0000															# Retrieve transmitter control ready bit
  blez $t0, main_instructions_userInput						# Check if a key was pressed

  jal getInput																		# Read keyboard input
  or $t6, $zero, $v0															# Backup direction from keyboard

  beq $t6, 0x02000000, main_clearInstructions			# Clear instructions if user pressed 'f' 
  beq $t6, 0x03000000, main_clearInstructions			# Clear instructions if user pressed 'j' 
  beq $t6, 0x04000000, main_exit									# Exit if user pressed 'f'

	j main_instructions_userInput										# Loop until valid key is pressed 

 
#
# Desc:
#		Clear instruction menu
#	Parameters:
#		none
# Returns:
#		none
#
main_clearInstructions:

	li $t0, 40																		  # x position
	li $t1, -175																		# y position
	li $t2, 393 																		# width
	li $t3, 104 																		# height
	la $t4, clear 																	# bitmap label
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	jal drawBitmap
	
	j main_generateUnits														# Jumping becuase user has already inputed a key


#	
# Desc:
# 	Wait for user to press a key to generate a unit
# Parameters:
#		none
# Returns:
#		none
#
main_generateUnits_userInput:
																								  # Wait for user to press a key
	lw $t0, 0xFFFF0000															# Retrieve transmitter control ready bit
  blez $t0, main_generateUnits_userInput					# Check if a key was pressed


#
# Desc:
# 	Get keyboard input to determine unit type
# Parameters:
#		none
# Returns:
#		none
#
main_generateUnits:
	jal getInput																		# Read keyboard input
	or $t6, $zero, $v0															# Backup direction from keyboard
	
	beq $t6, 0x04000000, main_exit									# Exit if user pressed 'x'


#
# Desc:
# 	Generate Paladin if 'f' was pressed
# Parameters:
#		none
# Returns:
#		none
#
main_generateUnitsLeft:
  bne $t6, 0x02000000, main_generateUnitsRight
  nop

  # store a paladin
  la $a0, PaladinWalk1
  jal store_unit


#
# Desc:
# 	Generate Mongol if 'j' was pressed
# Parameters:
#		none
# Returns:
#		none
#
main_generateUnitsRight:
  bne $t6, 0x03000000, main_done
  nop

  # store a mongol
  la $a0, MongolWalk1
  jal store_unit


#
# Desc:
# 	Render unit and return to wait for user input
# Parameters:
#		none
# Returns:
#		none
#
main_done:
  jal render
  b main_generateUnits_userInput


#
# Desc:
# 	Exit Program
# Parameters:
#		none
# Returns:
#		none
#
main_exit:
  li $v0, 10
  syscall




#
#  Parameters:
#    none
#  Returns:
#   none
#
render:
  # remember return address
  subu $sp, $sp, 4
  sw $ra, 0($sp)
  addi $sp, $sp, 4

  lw $s0, data # bottom of unit stack
  lw $s1, data_pointer

  read_unit:
    move $a0, $s0
    li $v0, 1
    syscall

    la $a0, new_line
    li $v0, 4
    syscall

    move $a0, $s1
    li $v0, 1
    syscall

    la $a0, new_line
    li $v0, 4
    syscall

    la $a0, new_line
    li $v0, 4
    syscall

    la $a0, new_line
    li $v0, 4
    syscall

    #j main_exit

    beq $s0, $s1, r_return # no more units

    lw $t0, ($s0) # get unit bitmap
    lw $t1, 4($s0) # x position
    lw $t2, 8($s0) # y position
    lw $t3, 12($s0) # health

    li $t4, 86
    li $t5, 107

    # do the drawing
    sw $t1, ($sp)     # x position
    sw $t2, 4($sp)    # y position
    sw $t4, 8($sp)    # width
    sw $t5, 12($sp)   # height
    sw $t0, 16($sp)   # height
    jal drawBitmap

    addi $s0, $s0, 16
    j read_unit

  r_return:
    subu $sp, $sp, 4
    lw $ra, ($sp)
    addu $sp, $sp, 4
    jr $ra  


#
#  Parameters:
#    $a0 --> the type of unit to store
#  Returns:
#   none
#
store_unit:
  lw $t0, data_pointer # HAHAHAHAHAHAHAHAHAHAHAH

  move $t1, $a0
  sw $t1, ($t0)
  addi $t0, $t0, 4
  li $t1, 440
  sw $t1, ($t0)
  addi $t0, $t0, 4
  li $t1, 50
  sw $t1, ($t0)
  addi $t0, $t0, 4
  li $t1, 100
  sw $t1, ($t0)
  addi $t0, $t0, 4
  sw $t0, data_pointer
  jr $ra


paladinWalk:
	li $t0, -50			# x position
	li $t1, 50			# y position
	li $t2, 86 			# width
	li $t3, 107 		#height
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)

	la $t4, PaladinWalk1
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, PaladinWalk2
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, PaladinWalk3
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, PaladinWalk4
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	j main_generateUnits_userInput	


mongolWalk:
	li $t0, 440
	li $t1, 50  
	li $t2, 86 
	li $t3, 107 
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)

	la $t4, MongolWalk1
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, MongolWalk2
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, MongolWalk3
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, MongolWalk4
	sw $t4, 16($sp)
	jal drawBitmap

	la $t4, clear
	sw $t4, 16($sp)
	jal drawBitmap

	j main_generateUnits_userInput	


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

      lw $t0, hot_pink
      beq $a2, $t0, db_skip # skip pink pixel
      jal drawPixel
      db_skip:

      addi $s4, $s4, 4 # increment color address

      addi $s6, $s6, 1
      j db_column

  db_end_row:
    addi $s5, $s5, 1
    j db_row

  db_return:
    jr $s7 # return


#
# Desc:
#		Reads ASCII code from Receiver Data register to get key input by user
# Parameters:
#		none
# Returns:
#   v0 = keyboard input
#
getInput:
  lw $t0, 0xFFFF0004    # Load input value
getInput_play:
  bne $t0, 112, getInput_left
  nop
  ori $v0, $zero, 0x01000000  # play
  j getInput_done
  nop
getInput_left:
  bne $t0, 102, getInput_right
  nop
  ori $v0, $zero, 0x02000000  # left
  j getInput_done
  nop
getInput_right:
  bne $t0, 106, getInput_exit
  nop
  ori $v0, $zero, 0x03000000  # right
  j getInput_done
  nop
getInput_exit:
  bne $t0, 120, getInput_none
  nop
  ori $v0, $zero, 0x04000000  # exit
  j getInput_done
  nop
getInput_none:
  # Do nothing
getInput_done:
  jr $ra        # Return
  nop
