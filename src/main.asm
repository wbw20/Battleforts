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

li $t0, 100
li $t1, 100
li $t2, 500
li $t3, 500
la $t4, list
addi $sp, $sp, -20
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $t4, 16($sp)

jal drawBitmap

j exit

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

  db_row:
    # at the end of this row?
    bltz $s2, dfr_return
    lw $s3, 12($sp)
    add $a0, $s0, $s2 # x coordinate

    db_column:
      # at the end of this column?
      bltz $s3, db_end_row
      add $a1, $s1, $s3 # y coordinate

      lw $a2, 0($s4) # load color

      jal drawPixel

      addi $s4, $s4, 4 # increment color address

      addi $s3, $s3, -1
      j db_column

  db_end_row:
    addi $s2, $s2, -1
    j db_row

  db_return:
    jr $ra # return


exit:
  li $v0, 10
  syscall