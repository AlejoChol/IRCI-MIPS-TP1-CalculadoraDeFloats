.data
float: .space 32
enter: .asciiz "\n"

.text

main:
	li $v0, 6
	syscall

	la $s0, float
	s.s $f0, ($s0)

	mov.s $f12, $f0
	li $v0, 2
	syscall

	la $a0, enter($0)
	li $v0, 4
	syscall

sg:
	lw $t0, ($s0)
	srl $a0, $t0, 31
	move $s1, $a0
	li $v0, 1
	syscall

	la $a0, enter($0)
	li $v0, 4
	syscall

exponente:
	lw $t0, ($s0)
	srl $a0, $t0, 23
	sll $a0, $a0, 1
	srl $a0, $a0, 1
	move $s2, $a0
	li $v0, 1
	syscall

	la $a0, enter($0)
	li $v0, 4
	syscall

mantisa:
	lw $t0, ($s0)
	sll $a0, $t0, 9
	srl $a0, $a0, 9
	move $s3, $a0
	li $v0, 1
	syscall


	
