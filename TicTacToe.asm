.data 
question1: .asciiz "What is your name Player X?\n"
question2: .asciiz "What is your name Player O?\n"
newLineCharacter: .asciiz "\n"
boardLine: .asciiz "=====\n"
playerName1: .space 20 # hopefully no one has more than 20 characters in their name.
playerName2: .space 20
greeting1: .asciiz "Hello "
greeting2: .asciiz "It's nice to meet you.\n"
turnMessage: .asciiz "Select square "
board: 
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
	.byte 0
.text

main:
	# get player one name
	la $a0, question1
	la $a1, playerName1
	jal greetAndMeet
	
	# get player two name
	la $a0, question2
	la $a1, playerName2
	jal greetAndMeet
	
	jal ticTacToe
	
	j exit
	
ticTacToe:
	addiu $sp, $sp, -4
	sw $ra, ($sp) # push ra to stack
	
	jal printBoard
	
	li $s7 0 # loop counter variable
	li $s6 1 # cur player turn

ticTacToeLoop:
	# ask question to current player
	la $a0, turnMessage
	jal printString
	beq $s6, 1, loadPlayerOneName
	b loadPlayerTwoName
loadPlayerOneName:
	la $a0, playerName1
	b askTurnQuestion
loadPlayerTwoName:
	la $a0, playerName2
askTurnQuestion:
	jal printString
	
	# get placement from user
	jal readInt
	
	# set array value
	move $t3, $v0
	subi $t3, $t3, 1
	sb $s6, board($t3)
	
	jal printBoard
	
	addi $s6, $s6, 1
	beq $s6, 3, resetPlayer
	b continuePlaying
resetPlayer:
	li $s6 1 # reset cur player turn
continuePlaying:
	
	addi $s7, $s7, 1
	bne $s7, 9, ticTacToeLoop # keep going if loop isn't finished
	
	lw $ra, ($sp) # pop ra from stack
	addiu $sp, $sp, 4
	jr $ra

# ---------------- Print Board Logic ------------------- #
printBoard:
	addiu $sp, $sp, -4
	sw $ra, ($sp) # push ra to stack
	
	li $s1, 0 # loop counter/index
	li $s2, 9 # loop max
	
printBoardLoop:
	beq $s1, 3, doNewLineForBoard
	beq $s1, 6, doNewLineForBoard
	beq $s1, 0, dontPrintAnythingAtBeginning
	b dontDoNewLineForBoard
doNewLineForBoard:
	jal newLine
	la $a0, boardLine
	jal printString
	b dontPrintAnythingAtBeginning
dontDoNewLineForBoard:
	li $a0, '|'
	li $v0, 11
	syscall
dontPrintAnythingAtBeginning:
	
	# print cur number, X, or O pending on current value in board at index/counter.
	lb $t1, board($s1)
	beqz $t1, printCurrentNumber
	beq $t1, 1, printX
	b printO
	
printCurrentNumber: # print current number
	move $a0, $s1
	addi $a0, $a0, 1
	li $v0, 1
	syscall
	
	addi $s1, $s1, 1
	bne $s1, $s2, printBoardLoop
	b printBoardEndLoop
printX:
	li $a0, 'X'
	li $v0, 11
	syscall
	
	addi $s1, $s1, 1
	bne $s1, $s2, printBoardLoop
	b printBoardEndLoop
printO:
	la $a0, 'O'
	li $v0, 11
	syscall
	
	addi $s1, $s1, 1
	bne $s1, $s2, printBoardLoop
	b printBoardEndLoop

printBoardEndLoop:
	jal newLine
	
	lw $ra, ($sp) # pop ra from stack
	addiu $sp, $sp, 4
	jr $ra

# ---------------- Player greetings ------------------- #	
greetAndMeet:
	addiu $sp, $sp, -4
	sw $ra, ($sp) # push ra to stack
	la $s1, ($a1) # save player name location in s1

	# ask question
	jal printString
	
	# get question from user
	la $a0, ($s1)
	jal readString
	
	# print greeting
	la $a0, greeting1
	jal printString
	la $a0, ($s1)
	jal printString
	la $a0, greeting2
	jal printString
	
	lw $ra, ($sp) # pop ra from stack
	addiu $sp, $sp, 4
	jr $ra

# ---------------- Helper functions ------------------- #
newLine:
	la $a0, newLineCharacter
printString:
	li $v0, 4
	syscall
	jr $ra

readString:
	li $v0, 8
	li $a1, 20
	syscall
	jr $ra

readInt:
	li $v0, 5
	syscall
	jr $ra
	
exit:
	li $v0, 10
	syscall 
