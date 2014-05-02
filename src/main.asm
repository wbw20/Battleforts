.data

# constants
height:         .word 512
width:          .word 512
word_size:      .word 4
hot_pink:       .word 0xff0080

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
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	jal clearBitmap


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
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	jal clearBitmap
	
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
	b paladinWalk

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
	b mongolWalk

	
#
# Desc:
# 	Render unit and return to wait for user input
# Parameters:
#		none
# Returns:
#		none
#
main_done:
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
# Desc:
# 	Moves paladins across the display
# Parameters:
#		none
# Returns:
#		none
#
paladinWalk:
	li $t0, -50			# x position
	li $t1, 50			# y position
	li $t2, 86 			# width
	li $t3, 107 		# height
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)

	la $t4, PaladinWalk1
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 0				# x position
	la $t4, PaladinWalk2
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 50				# x position
	la $t4, PaladinWalk3
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 100				# x position
	la $t4, PaladinWalk4
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, 150				# x position
	la $t4, PaladinWalk1
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, 200				# x position
	la $t4, PaladinWalk2
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, 250				# x position
	la $t4, PaladinWalk3
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 300				# x position
	la $t4, PaladinWalk4
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, 350				# x position
	la $t4, PaladinWalk1
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, 400				# x position
	la $t4, PaladinWalk2
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	j main_generateUnits_userInput	


#
# Desc:
# 	Moves mongols across the display
# Parameters:
#		none
# Returns:
#		none
#
mongolWalk:
	li $t0, 440			# x position
	li $t1, 50			# y position  
	li $t2, 86 			# width
	li $t3, 107 		# height
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)

	la $t4, MongolWalk1
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 390			# x position
	la $t4, MongolWalk2
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 340			# x position
	la $t4, MongolWalk3
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 340			# x position
	la $t4, MongolWalk4
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, 290			# x position
	la $t4, MongolWalk1
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 240			# x position
	la $t4, MongolWalk2
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 190			# x position
	la $t4, MongolWalk3
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 140			# x position
	la $t4, MongolWalk4
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, 90			# x position
	la $t4, MongolWalk1
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

	li $t0, 40			# x position
	la $t4, MongolWalk2
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap
	
	li $t0, -10			# x position
	la $t4, MongolWalk3
	sw $t0, 0($sp)
	sw $t4, 16($sp)
	jal drawBitmap

	jal clearBitmap

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

  lw $t5, display($t2)

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
#  Parameters:
#    0($sp) --> x coordinate
#    4($sp) --> y coordinate
#    8($sp) --> width
#   12($sp) --> height
#
clearBitmap:
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $s3, 12($sp)

  # x counter
  li $s5, 0

  # jal paints over $ra
  move $s7, $ra

  cb_row:
    # at the end of this row?
    beq $s2, $s5 cb_return

    # y counter
    li $s6, 0

    lw $s3, 12($sp)
    add $a0, $s0, $s5 # x coordinate

    cb_column:
      # at the end of this column?
      beq $s3, $s6, cb_end_row
      add $a1, $s1, $s6 # y coordinate

      lw $a2, hot_pink # load color
      jal drawPixel

      addi $s6, $s6, 1
      j cb_column

  cb_end_row:
    addi $s5, $s5, 1
    j cb_row

  cb_return:
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
