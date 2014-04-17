.data
str:        .ascii "0fff00"
error_str:  .asciiz "ERROR"

.text

la $a0, str
jal getColorValue
move $a0, $v0
jal printInt
j exit

# $a0 = address of string
getColorValue:
  la $s6, ($ra)   # return to main
  move $s4, $a0
  li $s7, 0       # return value
  move $a0, $s4
  jal getColorComponentValue
  move $t0, $v0
  sll $t0, $t0, 8
  sll $t0, $t0, 8
  add $s7, $s7, $t0
  la $a0, 2($s4)
  jal getColorComponentValue
  move $t0, $v0
  sll $t0, $t0, 8
  add $s7, $s7, $t0
  la $a0, 4($s4)
  jal getColorComponentValue
  add $s7, $s7, $v0
  move $v0, $s7
  jr $s6

# $a0 = address of first charcter
getColorComponentValue:
  la $s0, ($ra)		# original return address
  li $s1, 0       	# return value = 0
  la $s2, ($a0)		# character address
  lb $t3, 0($s2)	# character
  move $a0, $t3
  jal charToDecValue
  move $t4, $v0
  sll $t4, $t4, 4
  add $s1, $s1, $t4	# return value += val(str[0]) * 16 
  
  lb $t3, 1($s2)
  move $a0, $t3
  jal charToDecValue
  move $t4, $v0
  add $s1, $s1, $t4	# return value += val(str[1])
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
