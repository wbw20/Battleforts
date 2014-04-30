.data
fnf_err_str:    .ascii  "The file was not found: "
value_err_str:  .ascii  "ERROR"
dataFile:       .asciiz "built/pixels.txt"
cont:           .ascii  "file contents:\n"
buffer:         .space  3248   
bufferLength:   .word   812
pixelsPerChunk: .word   116
dataFileLength: .word   1598597   # number of characters
pixelCount:     .word   228371
pixelMemSize:   .word   913484    # pixelCount * 4
pixelsStrLength:.word   696   # pixelsPerChunk * 6 (length of hex-value substring)
numberOfImages: .word   20
imageOffsets:   .space  80        # number of images * 4 (word aligned)

################### Indexes in imageOffsets array ###################
BF_Menu_Index:  .word   0
Instruct_Index: .word   1
MFight1_Index:  .word   2
MFight2_Index:  .word   3
MFight3_Index:  .word   4
MFight4_Index:  .word   5
MFight5_Index:  .word   6
MWalk1_Index:   .word   7 
MWalk2_Index:   .word   8
MWalk3_Index:   .word   9
MWalk4_Index:   .word   10
PFight1_Index:  .word   11
PFight2_Index:  .word   12
PFight3_Index:  .word   13
PFight4_Index:  .word   14
PFight5_Index:  .word   15
PWalk1_Index:   .word   16
PWalk2_Index:   .word   17
PWalk3_Index:   .word   18
PWalk4_Index:   .word   19

.text

lw $a0, pixelMemSize       # allocate heap memory for pixel data
li $v0, 9
syscall

la $t0, imageOffsets       # initialize imageOffsets
li $t1, 0
sw $t1, ($t0)  

move $a0, $v0
jal readPixelsToHeap

j exit


# a0 = heap address
readPixelsToHeap:
  # Open File
  subu $sp, $sp, 8
  sw $a0, ($sp)
  sw $ra, 4($sp)

  open:
    li    $v0, 13        # Open File Syscall
    la    $a0, dataFile  # Load File Name
    li    $a1, 0         # Read-only Flag
    li    $a2, 0         # (ignored)
    syscall
    move  $s6, $v0       # Save File Descriptor
    blt   $v0, 0, fnf_error
   
  lw $s5, dataFileLength
  # Read Data
  readChunk:
    li    $v0, 14            # Read File Syscall
    move  $a0, $s6           # Load File Descriptor
    la    $a1, buffer        # Load Buffer Address     
    lw    $a2, bufferLength  # Load in chunk
    syscall
    subu $s5, $s5, $a2

  lw $a0, ($sp)
  jal translateBufferToHeap
  sw $v0, ($sp)
  li $v0, 1
  move $a0, $s5
  syscall
  bgtz $s5, readChunk

  # Close File
  close:
    li    $v0, 16        # Close File Syscall
    move  $a0, $s6       # Load File Descriptor
    syscall

  lw $ra, 4($sp)
  addu $sp, $sp, 8

  jr $ra

# $a0 = heap address
translateBufferToHeap:
  subu $sp, $sp, 4
  sw $ra, ($sp)
  move $a1, $a0
  la $a0, buffer
  jal parseString
  lw $ra, ($sp)
  addu $sp, $sp, 4
  jr $ra

# $a0 = address of full string
# $a1 = heap memory address
# returns heap memory address
parseString:
  move $s3, $a1       # beginning of allocated memory
  lw $t8, pixelsStrLength    # i = pixelsStrLength
  move $t9, $a0
  subu $sp, $sp, 8
  sw $ra, ($sp)        # store return address
  sw $a1, 4($sp)

  loopThroughString:        # while i > 0
    move $a0, $t9
    jal getColorValue
    sw $v0, ($s3)
    addi $s3, $s3, 4
    subu $t8, $t8, 6        # decrement i
    addi $t9, $t9, 6
    lb $t4, ($t9)
    beq $t4, '\n', addToimageOffsets    # comma or \n?

    readNextPixel:
    addi $t9, $t9, 1
    bnez $t8, loopThroughString
    j parse_return

    addToimageOffsets:
      lw $t0, pixelsStrLength
      subu $t0, $t0, $t8        # pixelsStrLength - i
      li $t2, 6
      divu $t0, $t2
      mflo $t0
      li $t2, 4
      multu $t0, $t2
      mflo $t0

      la $t1, imageOffsets
      loopThroughArray:
        lw $t2, ($t1)
        beq $t2, 0, insertNewIndex
        addi $t1, $t1, 4
        j loopThroughArray

      insertNewIndex:
        sw $t0, ($t1)                
  
      j readNextPixel

  parse_return:
    lw $ra, ($sp)
    lw $v0, 4($sp)
    addu $sp, $sp, 8
    move $v0, $s3
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
  j exit

fnf_error:
  li    $v0, 4        # Print String Syscall
  la    $a0, fnf_err_str    # Load Error String
  syscall
  j exit

exit:
li $v0, 10
syscall
