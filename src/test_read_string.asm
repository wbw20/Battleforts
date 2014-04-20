.data
str:        .ascii "0fff00000fff"
stringLength: .word 12
error_str:  .asciiz "ERROR"
new_line:   .ascii "\n"

.text

lw $a0, stringLength     # allocate heap memory for string
li $v0, 9 # syscall 9 (sbrk)
syscall
la $a0, str
move $a1, $v0
jal parseString
move $a0, $v0
jal printInt
li $v0, 4
la $a0, new_line
syscall

j exit

# $a0 = address of full string
# $a1 = heap memory address
# returns heap memory address
parseString:
  move $t7, $a1       # beginning of allocated memory
  lw $t8, stringLength
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
    addi $t9, $t9, 6
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
  add $s1, $s1, $t4	     # return value += val(str[0]) * 16 
  
  lb $t3, 1($s2)
  move $a0, $t3
  jal charToDecValue
  move $t4, $v0
  add $s1, $s1, $t4	     # return value += val(str[1])
  move $v0, $s1
  jr $s0


# $a0 = character
# returns int
charToDecValue:
  la $t3, 0($ra)	# original return address
  li $t2, 0	# sum = 0
  bltz $a0, error # < 0
  subi $t0, $a0, 'f'
  bgtz $t0, error # > 'f'

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

error:
  li $v0, 4
  la $a0, error_str
  syscall
  
exit:
  li $v0, 10
  syscall
