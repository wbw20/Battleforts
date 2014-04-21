.data

# constants
height:         .word 512
width:          .word 512
word_size:      .word 4

display:        .space 0x4000

.text


main_menu:
  li $t0, 80 
  li $t1, 0
  li $t2, 327 
  li $t3, 95 
  la $t4, Battleforts #Battleforts
  addi $sp, $sp, -20
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $t2, 8($sp)
  sw $t3, 12($sp)
  sw $t4, 16($sp)
  jal drawBitmap
  nop


main_waitLoop:
  # Wait for the player to press a key to begin the game
  jal sleep      
  nop
  lw $t0, 0xFFFF0000      # Retrieve transmitter control ready bit
  blez $t0, main_waitLoop    # Check if a key was pressed
  nop


main_play:
  jal getInput
  nop
  or $t6, $zero, $v0  # Backup direction from keyboard

  beq $t6, 0x04000000, main_exit
  nop

  bne $t6, 0x01000000, main_play
  nop


main_instructions:
  li $t0, 50
  li $t1, 0
  li $t2, 393 
  li $t3, 104 
  la $t4, Instructions #Battleforts
  addi $sp, $sp, -20
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $t2, 8($sp)
  sw $t3, 12($sp)
  sw $t4, 16($sp)
  jal drawBitmap
  nop


main_generateUnits:
  jal getInput
  nop
  or $t6, $zero, $v0  # Backup direction from keyboard

  beq $t6, 0x04000000, main_exit
  nop

main_generateUnitsLeft:
  bne $t6, 0x02000000, main_generateUnitsRight
  nop
  b paladinWalk
  nop


main_generateUnitsRight:
  bne $t6, 0x03000000, main_done
  nop
  b mongolWalk
  nop


main_done:
  b main_generateUnits


main_exit:
  li $v0, 10
  syscall



mongolWalk:
  li $t0, 450 
  li $t1, 175 
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

  j main_generateUnits
  nop


paladinWalk:
  li $t0, 0 
  li $t1, 150 
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

  j main_generateUnits
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
  ori $v0, $zero, 32    # Syscall sleep
  ori $a0, $zero, 60    # For this many miliseconds
  syscall
  jr $ra        # Return
  nop

#
#  Parameters:
#    none
#  Returns:
#   v0 = player(side) OR exit program
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
