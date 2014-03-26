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

li $a0, 100
li $a1, 100
li $a2, 100
li $a3, 100
addi $sp, $sp, -20
sw $a0, 0($sp)
sw $a1, 4($sp)
sw $a2, 8($sp)
sw $a3, 12($sp)
lw $t0, green
sw $t0, 16($sp)
jal drawFilledRectangle

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
#    $a0 --> x coordinate
#    $a1 --> y coordinate
#    $a2 --> width
#    $a3 --> height
#    $a4 --> color hex code
#
drawFilledRectangle:

  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t2, 8($sp)
  lw $t3, 12($sp)
  lw $t4, 16($sp)

  jr $ra # return

exit:
  li $v0,10
  syscall
