.data
enter: .asciiz "\n"
limpiar: .asciiz "0"
.align 2
float: .space 4
.align 2
msg_output1: .asciiz "El numero en memoria es: 0x"
msg_output2: .asciiz "El signo es: 0x"
msg_output3: .asciiz "El exponente es: 0x"
msg_output4: .asciiz "La mantisa es: 0x"
output: .asciiz "00000000\n"
hexa: .ascii "0123456789ABCDEF"


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


	lw $a0, 0($sp)
	jal sg
	addi $sp, $sp, -4
	sw $v0, 0($sp)

	la $a0, msg_output2
	li $v0, 4
	syscall
	
	lw $a0, 0($sp)
	jal print_string



	lw $a0, 4($sp)
	jal exponente
	addi $sp, $sp, -4
	sw $v0, 0($sp)

	la $a0, msg_output3
	li $v0, 4
	syscall
	
	lw $a0, 0($sp)
	jal print_string



	lw $a0, 8($sp)
	jal mantisa
	addi $sp, $sp, -4
	sw $v0, 0($sp)

	la $a0, msg_output4
	li $v0, 4
	syscall
	
	lw $a0, 0($sp)
	jal print_string

####################
	li $v0, 10
	syscall
####################



###########################################
# $a0: Float del cual extraer
###########################################
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

###########################################
# $a0: Float del cual extraer
###########################################
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

###########################################
# $a0: Float del cual extraer
###########################################
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

###########################################
# $a0: Numero a printear
###########################################
print_string:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	la $a1, output

	jal intAHex

	addi $sp, $sp, -4
	sw $v0, 0($sp)

	move $a0, $v0
	li $v0, 4
	syscall
	
	addi $sp, $sp, 4

	la $a0, enter
	li $v0, 4
	syscall

	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
	
	jr $ra


###########################################
# $a0: Numero a pasar a hex
# $a1: Direccion de output
###########################################
intAHex:addi $sp, $sp, -12	# Se reserva memoria del stack
	sw  $ra, 8($sp)
	sw  $a0, 4($sp)		# Guarda el numero ingresado
	sw  $a1, 0($sp)		# Guarda msg3* en el stack

	move $a0, $a1
	li $a1, 7
	jal limpiado_string

	
	lw  $a0, 4($sp)		# Guarda el numero ingresado
	lw  $a1, 0($sp)		# Guarda msg3* en el stack

	la   $t1, hexa		# Guarda 0123456789ABCDEF* en $t1
	li   $t2, 8		# Guarda un 8 en t2 (contador)
	addi $a1, $a1, 7	# Nos movemos 7 lugares -> (byte menos significativo de msg3)
L1:	andi $t0, $a0, 0xf	# Le hace un & con 1111. Es decir, agarra los primero 4 bits y los almacena en t0 \|/
	add  $t0, $t1, $t0	# Mueve el puntero al numero hexa deseado (en forma de char)
	lb   $t0, ($t0)		# Carga el hexa deseado (desde RAM)
	sb   $t0, ($a1)		# Lo guarda en la respuesta (en RAM)
	srl  $a0, $a0, 4	# Shiftea a los siguientes 4 bits del numero ingresado
	addi $a1, $a1, -1	# Movemos puntero a siguiente caracter respuesta (1 byte a la izquierda)
	addi $t2, $t2, -1	# Decrementamos contador
	beqz $t2, E1		# Cuando pasaron 32 bits (4 * 8) cortamos
	j L1
E1:	lw  $ra, 8($sp)		# Carga los argumentos del stack
	lw  $a0, 4($sp)		# Guarda el numero ingresado
	lw  $a1, 0($sp)		# Guarda msg3* en el stack
	addi $sp, $sp, 12	# Se reserva memoria del stack
	
	move $v0, $a1

	jr $ra

###########################################
# $a0: Direccion del string
# $a1: Largo del string
###########################################

limpiado_string:
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	la $t0, limpiar
	lb $t1, 0($t0)
	addi $a1, $a1, -1

limpiado_string_L1:
	beq $a1, $0, limpiado_string_E1
	addi $a1, $a1, -1
	sb $t1, 0($a0)

	j limpiado_string_L1

limpiado_string_E1:
	lw $ra, 8($sp)
	lw $a0, 4($sp)
	lw $a1, 0($sp)
	addi $sp, $sp, 12

	jr $ra

#############################################
	

