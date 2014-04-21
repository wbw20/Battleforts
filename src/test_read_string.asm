.data
fnf_err_str:    .ascii  "The file was not found: "
value_err_str:  .ascii "ERROR"
file:    .asciiz    "src/bmp_colors.txt"
cont:    .ascii  "file contents: "
buffer: .space 1024
test_str:        .ascii "0fff00,000fff,fff000"	# first value 1048320
new_line:   .ascii "\n"
fileLength: .word 18
imageIndices: .word 0


.text

jal readPixelsToBuffer

li $a0, 72      # allocate heap memory for string
li $v0, 9 	    # syscall 9 (sbrk)
syscall

la $a0, buffer
move $a1, $v0
jal parseString
move $s0, $v0
li $v0, 4
la $a0, new_line
syscall
lw $a0, 4($s0)
jal printInt
j exit


readPixelsToBuffer:
  # Open File
  open:
      li    $v0, 13        # Open File Syscall
      la    $a0, file    # Load File Name
      li    $a1, 0        # Read-only Flag
      li    $a2, 0        # (ignored)
      syscall
      move    $s6, $v0    # Save File Descriptor
      blt    $v0, 0, fnf_error    # Goto Error
   
  # Read Data
  read:
      li    $v0, 14        # Read File Syscall
      move    $a0, $s6    # Load File Descriptor
      la    $a1, buffer    # Load Buffer Address
      li    $a2, 1024    # Buffer Size
      syscall
   
  print:
      li    $v0, 4        # Print String Syscall
      la    $a0, cont    # Load Contents String
      syscall
   
  # Close File
  close:
      li    $v0, 16        # Close File Syscall
      move    $a0, $s6    # Load File Descriptor
      syscall

  jr $ra

# $a0 = address of full string
# $a1 = heap memory address
# returns heap memory address
parseString:
  move $t7, $a1       # beginning of allocated memory
  lw $t8, fileLength
  move $t9, $a0
  subu $sp, $sp, 8
  sw $ra, ($sp)        # store return address
  sw $a1, 4($sp)

  loopThroughString:
    move $a0, $t9
    jal getColorValue
    sw $v0, ($t7)
    addi $t7, $t7, 4
    subu $t8, $t8, 6
    addi $t9, $t9, 7
    #beq $t9, '\n', addToImageIndices
    bnez $t8, loopThroughString

  lw $ra, ($sp)
  lw $v0, 4($sp)
  addu $sp, $sp, 8
  jr $ra

# $a0 = address of initial character in substring
getColorValue:
  li $v0, 0           # return value
  subu $sp, $sp, 12
  sw $v0, ($sp)       # store return value
  sw $a0, 4($sp)      # store address of string
  sw $ra, 8($sp)      # store return address
  jal getColorComponentValue
  move $t0, $v0
  sll $t0, $t0, 8       # multiply first position by 256 * 256
  sll $t0, $t0, 8
  lw $v0, ($sp)
  add $v0, $v0, $t0
  sw $v0, ($sp)         # store new return value
  lw $t1, 4($sp)        # load string address
  la $a0, 2($t1)        # offset address for next two characters
  jal getColorComponentValue
  move $t0, $v0
  sll $t0, $t0, 8       # multiply second position by 256
  lw $v0, ($sp)
  add $v0, $v0, $t0
  sw $v0, ($sp)
  lw $t1, 4($sp)
  la $a0, 4($t1)
  jal getColorComponentValue
  move $t0, $v0
  lw $v0, ($sp)
  add $v0, $v0, $t0
  lw $ra, 8($sp)
  addu $sp, $sp, 12
  jr $ra

# $a0 = address of first charcter
getColorComponentValue:
  la $s0, ($ra)		       # original return address
  li $s1, 0       	     # return value = 0
  la $s2, ($a0)		       # character address
  lb $t3, 0($s2)	       # character
  move $a0, $t3
  jal charToDecValue
  move $t4, $v0
  sll $t4, $t4, 4
  add $s1, $s1, $t4	     # return value += val(buffer[0]) * 16 
  
  lb $t3, 1($s2)
  move $a0, $t3
  jal charToDecValue
  move $t4, $v0
  add $s1, $s1, $t4	     # return value += val(buffer[1])
  move $v0, $s1
  jr $s0


# $a0 = character
# returns int
charToDecValue:
  la $t3, 0($ra)	# original return address
  li $t2, 0	# sum = 0
  bltz $a0, value_error # < 0
  subi $t0, $a0, 'f'
  bgtz $t0, value_error # > 'f'

  subi $t0, $a0, 'a'
  bltzal $t0, belowTen # $t1 < 'a'
  bgezal $t0, aboveTen
  move $v0, $t2
  jr $t3

  belowTen:
    subi $t1, $a0, '0'
    add $t2, $t2, $t1 # sum += $t1 - '0'
    jr $ra
    
  aboveTen:
    subi $t1, $a0, 'a'
    addi $t1, $t1, 10
    add $t2, $t2, $t1 # sum += $t1 - 'a' + 10
    jr $ra

# $a0 = integer
printInt:
  li $v0, 1
  syscall
  jr $ra

value_error:
  li $v0, 4
  la $a0, value_err_str
  syscall

fnf_error:
    li    $v0, 4        # Print String Syscall
    la    $a0, fnf_err_str    # Load Error String
    syscall

exit:
li $v0, 10
syscall