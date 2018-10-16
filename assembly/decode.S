#include <mips/regdef.h>
#include <sys/syscall.h>

#define RETURNO_OK 1
#define DECODE_ERROR   100
#define SIZE_DECODE_CHAR 4

#define SHIFT_2 2
#define SHIFT_4 4
#define SHIFT_6 6

#define EQUAL_CHAR 61

#define STACK_FRAME_DECODECHAR 32

#define OFFSET_FP_DECODECHAR 32
#define OFFSET_GP_DECODECHAR 28
#define OFFSET_CHARACTER_DECODECHAR 16
#define OFFSET_I_DECODECHAR 20
#define OFFSET_RETURN_DECODECHAR 24

#define STACK_FRAME_DECODE 64

#define OFFSET_BUFFER_OUTPUT_ENCODE 68
#define OFFSET_BUFFER_INPUT_ENCODE 64
#define OFFSET_RA_DECODE 60
#define OFFSET_FP_DECODE 56
#define OFFSET_GP_DECODE 52
#define OFFSET_S0_DECODE 48
#define OFFSET_CHAR1_AUX_ENCODE 37
#define OFFSET_CHAR0_AUX_ENCODE 36
#define OFFSET_CHARS3_ENCODE 27
#define OFFSET_CHARS2_ENCODE 26
#define OFFSET_CHARS1_ENCODE 25
#define OFFSET_CHARS0_ENCODE 24
#define OFFSET_RETURN_ENCODE 20
#define OFFSET_I_DECODE 32

	.file	1 "decode.c"
	#.section .mdebug.abi32
	#.previous
	#.abicalls
	.data
	.align	2
	.type	encoding_table, @object
	.size	encoding_table, 64
encoding_table:
	.byte	65
	.byte	66
	.byte	67
	.byte	68
	.byte	69
	.byte	70
	.byte	71
	.byte	72
	.byte	73
	.byte	74
	.byte	75
	.byte	76
	.byte	77
	.byte	78
	.byte	79
	.byte	80
	.byte	81
	.byte	82
	.byte	83
	.byte	84
	.byte	85
	.byte	86
	.byte	87
	.byte	88
	.byte	89
	.byte	90
	.byte	97
	.byte	98
	.byte	99
	.byte	100
	.byte	101
	.byte	102
	.byte	103
	.byte	104
	.byte	105
	.byte	106
	.byte	107
	.byte	108
	.byte	109
	.byte	110
	.byte	111
	.byte	112
	.byte	113
	.byte	114
	.byte	115
	.byte	116
	.byte	117
	.byte	118
	.byte	119
	.byte	120
	.byte	121
	.byte	122
	.byte	48
	.byte	49
	.byte	50
	.byte	51
	.byte	52
	.byte	53
	.byte	54
	.byte	55
	.byte	56
	.byte	57
	.byte	43
	.byte	47
	.align	2
	.type	encoding_table_size, @object
	.size	encoding_table_size, 4

encoding_table_size:
	.word	64
	.text
	.align	2
	.globl	DecodeChar
	.ent	DecodeChar
	
	####### Begin Función DecodeChar #######

DecodeChar:
	# Reservo espacio para el stack frame de STACK_FRAME_DECODECHAR bytes
	.frame	$fp,STACK_FRAME_DECODECHAR,ra		# vars= 8, regs= 2/0, args= 0, extra= 8
	#.mask	0x50000000,-4
	#.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder
	
	# Creación del stack frame STACK_FRAME_DECODECHAR
	subu	sp,sp,STACK_FRAME_DECODECHAR
	.cprestore 0
	
	# Guardo fp y gp en el stack frame
	sw	$fp,OFFSET_FP_DECODECHAR(sp)
	sw	gp,OFFSET_GP_DECODECHAR(sp)
	# De aquí al final de la función uso $fp en lugar de sp.
	move	$fp,sp
	
	# Guardo en v0 el parámetro recibido: 'character'.
	move	v0,a0
	# Guardo en el stack frame 'character'.
	sb	v0,OFFSET_CHARACTER_DECODECHAR($fp)
	# Guardo en un '0' en el stack frame.
	# Inicializo la variable 'i'.
	sb	zero,OFFSET_I_DECODECHAR($fp)
condition_loop:	
	# Cargo en v0 el byte guardado anteriormente(0 o el nuevo valor de 'i').
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	# Cargo en v1 el size del encoding_table(64).
	lw	v1,encoding_table_size
	# Si (i < encoding_table_size), guardo TRUE en v0, sino FALSE.
	slt	v0,v0,v1
	# Salto a condition_if si v0 != 0.
	bne	v0,zero,condition_if
	# Brancheo a condition_if_equal
	b	condition_if_equal
condition_if:	
	# Cargo en v0 el valor de 'i'.
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	# Cargo en v1 el byte contenido en encoding_table según el valor de 'i'.
	# encoding_table[i]
	lbu	v1,encoding_table(v0)
	# Cargo en v0 'character'.
	lb	v0,OFFSET_CHARACTER_DECODECHAR($fp)
	# Salto a increase_index si el valor recuperado del vector encoding_table
	# es distinto al valor pasado por parámetro(character).
	bne	v1,v0,increase_index
	# Cargo en v0 nuevamente el valor de 'i'.
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	
	# Guardo en el stack frame(12) el valor de 'i'
	#sw	v0,12($fp) #VER
	sw v0,OFFSET_RETURN_DECODECHAR($fp)

	# Brancheo a return_decode_index_or_zero
	b	return_decode_index_or_zero
increase_index:
	# Cargo en v0 nuevamente el valor de 'i'.
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	# Sumo en 1 el valor de 'i'(i++).
	addu	v0,v0,1
	# Guardo el valor modificado en el stack frame.
	sb	v0,OFFSET_I_DECODECHAR($fp)
	# Salto a condition_loop
	b	condition_loop
condition_if_equal:
	# Cargo en v1 el byte(char) recibido como parámetro.
	# parametro: character.
	lb	v1,OFFSET_CHARACTER_DECODECHAR($fp)
	# Cargo en v0 el inmediato EQUAL_CHAR=61(corresponde a el char '=').
	li	v0,EQUAL_CHAR			# 0x3d
	# Salto a return_decode_error si el char recibido por parámetro no es igual a '='.
	bne	v1,v0,return_decode_error
	# Guardo un 0(DECODE_EQUAL) en el stack frame(12).
	sw	zero,OFFSET_RETURN_DECODECHAR($fp)
	# Salto a return_decode_index_or_zero.
	b	return_decode_index_or_zero
return_decode_error:
	# Cargo en v0 el inmediato DECODE_ERROR=100
	li	v0,DECODE_ERROR			# 0x64
	# Guardo el DECODE_ERROR en el stack frame.
	sw	v0,OFFSET_RETURN_DECODECHAR($fp)
return_decode_index_or_zero:
	# Cargo en v0 el valor retornado por DecodeChar
	lw	v0,OFFSET_RETURN_DECODECHAR($fp)
	
	move	sp,$fp
	# Restauro fp
	lw	$fp,OFFSET_FP_DECODECHAR(sp)
	# Destruyo el stack frame
	addu	sp,sp,STACK_FRAME_DECODECHAR
	# Regreso el control a la función llamante.
	j	ra
	.end	DecodeChar
	#.size	DecodeChar, .-DecodeChar

	#######	End Función DecodeChar #######

	#######	Begin Función Decode #######

	.align	2
	.globl	Decode
	.ent	Decode
Decode:
	.frame	$fp,STACK_FRAME_DECODE,ra		# vars= 24, regs= 4/0, args= 16, extra= 8
	#.mask	0xd0010000,-4
	#.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder
	
	# Creación del stack frame
	subu	sp,sp,STACK_FRAME_DECODE
	.cprestore 16
	
	sw	ra,OFFSET_RA_DECODE(sp)
	sw	$fp,OFFSET_FP_DECODE(sp)
	sw	gp,OFFSET_GP_DECODE(sp)
	sw	s0,OFFSET_S0_DECODE(sp)

	# De aquí al final de la función uso $fp en lugar de sp.
	move	$fp,sp
	
	# Guardo en el stack frame los parámetros recibidos.
	# a0=puntero a buffer_input
	sw	a0,OFFSET_BUFFER_INPUT_ENCODE($fp)
	# Guardo en el stack frame los parámetros recibidos.
	# a1=puntero a buffer_output
	sw	a1,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	# Guardo un 0 en el stack frame(OFFSET_I_DECODE). Inicializo 'i'.
	sw	zero,OFFSET_I_DECODE($fp)
loop_decode_char:
	# Cargo en v0 el valor de 'i' guardado en el stack frame.
	lw	v0,OFFSET_I_DECODE($fp)
	# Si (i < SIZE_DECODE_CHAR), guardo TRUE en v0, sino FALSE.
	sltu	v0,v0,SIZE_DECODE_CHAR
	# Salto a if_decode_char si sigo dentro del bucle.
	bne	v0,zero,if_decode_char
	# Salto a main_shift
	b	main_shift
if_decode_char:
	# Cargo en v1 el valor de 'i'.
	lw	v1,OFFSET_I_DECODE($fp)
	# Cargo en v0 el valor de fp + OFFSET_CHARS0_ENCODE ???
	addu	v0,$fp,OFFSET_CHARS0_ENCODE
	# Cargo en s0 el valor de buf_input[i]
	addu	s0,v0,v1
	# Cargo en v1 el puntero a buf_input
	lw	v1,OFFSET_BUFFER_INPUT_ENCODE($fp)
	# Cargo en v0 el valor de 'i'.
	lw	v0,OFFSET_I_DECODE($fp)
	# Me desplazo por el vector(buf_input[i])
	addu	v0,v1,v0
	# Cargo en v0 el valor del buf_input[i](1 byte).
	lb	v0,0(v0)
	# Asigna el valor del byte a a0 antes de llamar a la función.
	move	a0,v0
	# Carga en t9 la direccion de la funcion DecodeChar.
	la	t9,DecodeChar
	# Hace el llamado a la función.
	jal	ra,t9
	# Guardo en s0 el resultado de la función.
	# El valor regresa en el registro v0
	sb	v0,0(s0)
	# Cargo en v1 el valor de 'i'.
	lw	v1,OFFSET_I_DECODE($fp)
	# Cargo en v0 el valor de fp + OFFSET_CHARS_ENCODE ???
	addu	v0,$fp,OFFSET_CHARS0_ENCODE
	# Cargo en v0 el valor de chars[i](direccion).
	addu	v0,v0,v1
	# Cargo en v1 el byte apuntado.
	lbu	v1,0(v0)
	# Cargo en v0 el DECODE_ERROR
	li	v0,DECODE_ERROR			# 0x64
	# Si chars[i] != DECODE_ERROR salto a increase_index_decode
	bne	v1,v0,increase_index_decode
	# Guarda en el stack frame un 0.
	sw	zero,OFFSET_RETURN_ENCODE($fp)
	# Si chars[i] == DECODE_ERROR retorno un 0.
	b	return_zero
increase_index_decode:
	# Cargo en v0 el valor de 'i'.
	lw	v0,OFFSET_I_DECODE($fp)
	# Sumo en 1 el valor de 'i'(i++). 
	addu	v0,v0,1
	# Guardo el valor modificado en el stack frame.
	sw	v0,OFFSET_I_DECODE($fp)
	# Salto a loop_decode_char
	b	loop_decode_char
main_shift:	
	# Cargo en v0 la dirección de chars[0]
	lbu	v0,OFFSET_CHARS0_ENCODE($fp)
	# Hago un shift left logical de SHIFT_2 y lo asigno a v0.
	sll	v0,v0,SHIFT_2
	# Guardo el valor en el stack frame.
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Cargo el valor de chars[1] en v0.
	lbu	v0,OFFSET_CHARS1_ENCODE($fp)
	# Hago un shift left logical de SHIFT_2 y lo asigno a v0.
	srl	v0,v0,SHIFT_4
	# Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	# Cargo en v1 char1_aux(chars[0] luego de ser shifteado).
	lbu	v1,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Cargo en v0 char2_aux(chars[1] luego de ser shifteado).
	lbu	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	# Hago un or de v1 y v0 y lo asigno a v0.
	or	v0,v1,v0
	# Guardo en valor en el stack frame.
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Cargo en v1 el puntero al buffer_output.
	lw	v1,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	# Cargo en v0 char1_aux(chars[0] luego de ser shifteado).
	lbu	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Guardo en el vector buffer_output el valor de char1_aux.
	sb	v0,0(v1)
	# Cargo el valor de chars[1] en v0.
	lbu	v0,OFFSET_CHARS1_ENCODE($fp)
	# Hago un shift left de 4 posiciones y lo guardo en v0.
	sll	v0,v0,SHIFT_4
	# Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Cargo en v0 chars[2].
	lbu	v0,OFFSET_CHARS2_ENCODE($fp)
	# Hago un shift rigth de 2 de chars[2] y lo guardo en v0.
	srl	v0,v0,SHIFT_2
	# Guardo en stack frame el valor shifteado.
	sb	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	# Cargo en v1 y v0 los valores shifteados anteriormente.
	lbu	v1,OFFSET_CHAR1_AUX_ENCODE($fp)
	lbu	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Hago un or de v1 y v0 y lo asigno a v0.
	or	v0,v1,v0
	# Vuelvo a guardar en el stack frame el resultado del or.
	# (**)
	sb	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	# Cargo en v0 el puntero al buffer_output.
	lw	v0,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	# Sumo 1 al puntero para desplazarme dentro del vector.
	# Luego asigno el resultado a v1.
	addu	v1,v0,1
	# Cargo en v0 el resultado de (**).
	lbu	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	# Guardo en el vector buffer_output el valor (**).
	sb	v0,0(v1)
	# Cargo en v0 chars[2]
	lbu	v0,OFFSET_CHARS2_ENCODE($fp)
	# Hago un shift left de 6.
	sll	v0,v0,SHIFT_6
	# Guardo en el stack frame el valor shifteado.
	# (***)
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Cargo en v0 el puntero al buffer_output.
	lw	v0,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	# Sumo 2 al puntero para desplazarme dentro del vector buffer_output.
	# Luego asigno el resultado a a0.
	addu	a0,v0,2
	# Cargo en v1 el ultimo valor shifteado (***).
	lbu	v1,OFFSET_CHAR0_AUX_ENCODE($fp)
	# Cargo en v0 chars[3]
	lbu	v0,OFFSET_CHARS3_ENCODE($fp)
	# Hago un or de v1 y v0 y lo asigno a v0.
	or	v0,v1,v0
	# Guardo en el vector buffer_output el resultado del or. 
	sb	v0,0(a0)
	# Cargo en v0 el inmediato 1(RETURNO_OK).
	li	v0,RETURNO_OK			# 0x1
	# Guardo en el stack frame el valor de retorno.
	sw	v0,OFFSET_RETURN_ENCODE($fp)
return_zero:
	# Cargo en v0 el valor salvado en el stack frame(0).
	lw	v0,OFFSET_RETURN_ENCODE($fp)
	move	sp,$fp

	# Restauro ra,fp y gp.
	lw	ra,OFFSET_RA_DECODE(sp)
	lw	$fp,OFFSET_FP_DECODE(sp)
	lw	s0,OFFSET_S0_DECODE(sp)

	# Destruyo el stack frame.
	addu	sp,sp,STACK_FRAME_DECODE
	# Devuelvo el control a la función llamante.
	j	ra

	.end	Decode
	#.size	Decode, .-Decode
	#.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
