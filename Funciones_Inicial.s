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

	la $s0, float	#Lo guardo en float
	s.s $f0, ($s0)

	mov.s $f12, $f0	#Re-Envio el float ingresado (para control)
	li $v0, 2
	syscall

	la $a0, enter($0)
	li $v0, 4
	syscall

sg:
	lw $t0, ($s0)		#
	srl $a0, $t0, 31	# || <- movemos 31 bits hasta el signo
        andi $a0, $a0, 0x1	#
	move $s1, $a0		#	x ... x y |hacemos un andi y conseguimos SOLO el signo 
	li $v0, 1		#		1 |
	syscall			#

	la $a0, enter($0)
	li $v0, 4
	syscall

exponente:
	lw $t0, ($s0)		#
	srl $a0, $t0, 23	# ||_______| <- movemos 23 bits hasta el exponente
        andi $a0, $a0, 0xff	#
	move $s2, $a0		# ||_______|	|hacemos un andi y conseguimos SOLO el exponente
	li $v0, 1		#  11111111	|
	syscall			#

	la $a0, enter($0)
	li $v0, 4
	syscall

mantisa:
	lw $t0, ($s0)		#
        sll  $a0, $t0, 9	#  movemos 9 bits a la izquierda  -> |______________________|
        srl  $a0, $a0, 9	#
	move $s3, $a0		#
	li $v0, 1		#
	syscall

