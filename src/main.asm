.data

fin: .asciiz "bmp_colors.txt"      # filename for input

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

jal loadImageData

li $t0, 0
li $t1, 0
li $t2, 42
li $t3, 63
la $t4, 0($v0)
addi $sp, $sp, -20
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $t4, 16($sp)

jal drawBitmap

j exit


loadImageData:

  li   $v0, 13       # system call for open file
  la   $a0, fin      # board file name
  li   $a1, 0        # Open for reading
  li   $a2, 0
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 

  li $a0, 1024
  li $v0 9 # syscall 9 (sbrk)
  syscall

  la $t0, 0($v0)  # address for start of heap memory

  #read from file
  li   $v0, 14       # system call for read from file
  move $a0, $s6      # file descriptor 
  la   $a1, 0($t0)   # address of buffer to which to read
  li   $a2, 10000     # hardcoded buffer length
  syscall            # read from file

  # Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file

  la $v0, 0($t0)
  jr $ra


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

  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t2, 8($sp)
  lw $t3, 12($sp)
  lw $t4, 16($sp)

  db_row:
    # at the end of this row?
    bltz $t2, db_return
    lw $t3, 12($sp)
    add $a0, $t0, $t2 # x coordinate

    db_column:
      # at the end of this column?
      bltz $t3, db_end_row
      add $a1, $t1, $t3 # y coordinate

      lw $a2, 0($t4) # load color

      jal drawPixel

      addi $t4, $t4, 4 # increment color address

      addi $t3, $t3, -1
      j db_column

  db_end_row:
    addi $t2, $t2, -1
    j db_row

  db_return:
    jr $ra # return


exit:
  li $v0, 10
  syscall
