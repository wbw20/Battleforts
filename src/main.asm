.data

include "colors.asm"
include "constants.asm"

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

include "drawing/drawing.asm"

exit:
  li $v0, 10
  syscall
