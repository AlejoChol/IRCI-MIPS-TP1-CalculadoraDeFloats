.data
enter: .asciiz "\n"
.align 2
float: .space 4

.text

#Funciones basicas para conseguir las componentes
#------------------------------------------------
#(sin uso del stack ni pasar a hexa, proof of concept)
#
#	_________________________________
#	||_______|______________________|
#	signo:		mantisa:	
#	1 bit		23 bits
#
#	 exponente:
#	 8

main:
	li $v0, 6	#Cargo el float sp
	syscall

	la $t0, float	#Lo guardo en float
	s.s $f0, ($t0)

	addi $sp, $sp, -4
	sw $t0, 0($sp)

	mov.s $f12, $f0	#Re-Envio el float ingresado (para control)
	li $v0, 2
	syscall

	la $a0, enter
	li $v0, 4
	syscall



	lw $a0, 0($sp)
	



	jal sg

	addi $sp, $sp, -4
	sw $v0, 0($sp)

	move $a0, $v0

	jal print_basico



	lw $a0, 4($sp)
	
	jal exponente

	addi $sp, $sp, -4
	sw $v0, 0($sp)

	move $a0, $v0

	jal print_basico



	lw $a0, 8($sp)
	
	jal mantisa

	addi $sp, $sp, -4
	sw $v0, 0($sp)

	move $a0, $v0

	jal print_basico

####################
	li $v0, 10
	syscall
####################



sg:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
	
	lw $t0, ($a0)		#
	srl $t0, $t0, 31	# || <- movemos 31 bits hasta el signo
        andi $t0, $t0, 0x1	#
	move $v0, $t0		#	x ... x y |hacemos un andi y conseguimos SOLO el signo 
	
	addi $sp, $sp, -4
	sw $v0, 0($sp)

	lw $a0, 8($sp)
	lw $ra, 4($sp)
	lw $v0, 0($sp)
	addi $sp, $sp, 12


	jr $ra

exponente:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)

	lw $t0, ($a0)		#
	srl $t0, $t0, 23	# ||_______| <- movemos 23 bits hasta el exponente
        andi $t0, $t0, 0xff	#
	move $v0, $t0		# ||_______|	|hacemos un andi y conseguimos SOLO el exponente
	
	addi $sp, $sp, -4
	sw $v0, 0($sp)


	lw $a0, 8($sp)
	lw $ra, 4($sp)
	lw $v0, 0($sp)
	addi $sp, $sp, 12

	jr $ra

mantisa:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)

	lw $t0, ($a0)		#
        sll  $t0, $t0, 9	#  movemos 9 bits a la izquierda  -> |______________________|
        srl  $t0, $t0, 9	#
	move $v0, $t0		#

	addi $sp, $sp, -4
	sw $v0, 0($sp)


	lw $a0, 8($sp)
	lw $ra, 4($sp)
	lw $v0, 0($sp)
	addi $sp, $sp, 12

	jr $ra

print_basico:

	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)

	li $v0, 1
	syscall

	la $a0, enter
	li $v0, 4
	syscall

	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
	
	jr $ra



