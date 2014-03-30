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

  row:
    # at the end of this row?
    bltz $s2, dfr_return
    lw $s3, 12($sp)
    add $a0, $s0, $s2 # x coordinate

    column:
      # at the end of this column?
      bltz $s3, end_row
      add $a1, $s1, $s3 # y coordinate

      jal drawPixel

      addi $s3, $s3, -1
      j column

  end_row:
    addi $s2, $s2, -1
    j row

  dfr_return:
    jr $ra # return
