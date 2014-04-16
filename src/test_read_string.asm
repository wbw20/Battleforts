.data
str:        .ascii "7"
error_str:  .asciiz "ERROR"

.text

la $t0, str
lb $t1, 0($t0)
move $a0, $t1
jal charToDecValue
move $a0, $v0
jal printInt
j exit

# $a0 = character
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
