.data
str: .ascii "f"
error_str: .asciiz "ERROR"

.text


la $t0 str
lb $t1 0($t0)

bltz $t1, error # < 0
subi $t2, $t1, 'f'
bgtz $t2, error # > 'f'

subi $t2, $t1, 'a'
bltzal $t2, belowTen # $t1 < 'a'
bgezal $t2, aboveTen
jal printInt
j exit

  belowTen:
    subi $t3, $t1, '0'
    add $t4, $t4, $t3 # sum += $t1 - '0'
    jr $ra
    
  aboveTen:
    subi $t3, $t1, 'a'
    addi $t3, $t3, 10
    add $t4, $t4, $t3 # sum += $t1 - 'a' + 10
    jr $ra

printInt:
  li $v0, 1
  move $a0, $t4
  syscall
  jr $ra

error:
  li $v0, 4
  la $a0, error_str
  syscall
  
exit:
  li $v0, 10
  syscall
