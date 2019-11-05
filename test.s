.data
msg1: .asciiz "00000001\n"
limpiar: .asciiz ""
.text
main:	li $v0, 4             #
	la $a0, msg1          #
	syscall               # Imprime msg1

	la $t0, limpiar
	sb $0, 5($a0)

	li $v0, 4             #
	la $a0, msg1          #
	syscall               # Imprime msg1
