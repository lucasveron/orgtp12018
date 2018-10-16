#include <mips/regdef.h>
#include <sys/syscall.h>

#define STACK_FRAME_ENCODE 16

#define OFFSET_OUTPUT_ENCODE 24
#define OFFSET_LENGTH_ENCODE 20
#define OFFSET_BUFFER_ENCODE 16
#define OFFSET_FP_ENCODE 12
#define OFFSET_GP_ENCODE 8

#define OFFSET_B4_AUX 7
#define OFFSET_B3_AUX_2 6
#define OFFSET_B3_AUX 5
#define OFFSET_B2_AUX 4
#define OFFSET_B1_AUX 3
#define OFFSET_B3 2
#define OFFSET_B2 1
#define OFFSET_B1 0

#define EQUAL_CHAR 61

	.file	1 "encode.c"
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
	.text
	.align	2
	.globl	Encode
	.ent	Encode

	#######	Función Encode #######

Encode:
	.frame	$fp,STACK_FRAME_ENCODE,ra		# vars= 8, regs= 2/0, args= 0, extra= 8
	#.mask	0x50000000,-4
	#.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder

	# Creación del stack frame
	subu	sp,sp,STACK_FRAME_ENCODE

	.cprestore 0
	sw	$fp,OFFSET_FP_ENCODE(sp)
	sw	gp,OFFSET_GP_ENCODE(sp)
	
	# De aquí al final de la función uso $fp en lugar de sp.
	move	$fp,sp
	
	# Guardo el primer parámetro *buffer
	sw	a0,OFFSET_BUFFER_ENCODE($fp)
	# Guardo el segundo parámetro 'length'(cantidad de caracteres)
	sw	a1,OFFSET_LENGTH_ENCODE($fp)
	# Guardo el puntero al array de salida(output)
	sw	a2,OFFSET_OUTPUT_ENCODE($fp)
	
	# Cargo en v0 el puntero al buffer.
	lw	v0,OFFSET_BUFFER_ENCODE($fp)
	# Cargo en v0 el 1er byte del buffer.
	lbu	v0,0(v0)
	# Guardo el 1er byte en el stack frame
	sb	v0,OFFSET_B1($fp)
	# Cargo nuevamente la dirección del buffer.
	lw	v0,OFFSET_BUFFER_ENCODE($fp)
	# Aumento en 1(1 byte) la dirección del buffer.
	# Me muevo por el array del buffer.
	addu	v0,v0,1
	# Cargo el 2do byte del buffer.
	lbu	v0,0(v0)
	# Guardo el 2do byte en el stack frame.
	sb	v0,OFFSET_B2($fp)
	# Cargo nuevamente la dirección del buffer.
	lw	v0,OFFSET_BUFFER_ENCODE($fp)
	# Aumento en 2(2 byte) la dirección del buffer.
	# Me muevo por el array del buffer.
	addu	v0,v0,2
	# Cargo el 2do byte del buffer.
	lbu	v0,0(v0)
	# Guardo el 3er byte en stack frame.
	sb	v0,OFFSET_B3($fp)
	# Cargo en v0 el 1er byte.
	lbu	v0,OFFSET_B1($fp)
	# Muevo 2 'posiciones' hacia la derecha(shift 2).
	srl	v0,v0,2
	# Guardo el nuevo byte en una variable auxiliar.
	sb	v0,OFFSET_B1_AUX($fp)
	# Cargo en v1 el puntero al output.
	lw	v1,OFFSET_OUTPUT_ENCODE($fp)
	# Cargo en v0 el byte shifteado.
	lbu	v0,OFFSET_B1_AUX($fp)
	# Cargo en v0 el caracter(byte) de la tabla encoding(encoding_table)
	lbu	v0,encoding_table(v0)
	# Cargo en v0 el 1er byte de la dirección del output.
	sb	v0,0(v1)
	# Cargo en v0 el 1er byte del buffer nuevamente.
	lbu	v0,OFFSET_B1($fp)
	# Muevo 6 'posiciones' hacia la izquierda(shift 6). 
	sll	v0,v0,6
	# Guardo el resultado del shift en el Stack Frame.
	sb	v0,OFFSET_B2_AUX($fp)
	# Cargo el byte sin signo shifteado.
	lbu	v0,OFFSET_B2_AUX($fp)
	# Muevo 2 'posiciones' hacia la derecha(shift 2).
	srl	v0,v0,2
	# Guardo el nuevo resultado del shift en el Stack Frame.
	sb	v0,OFFSET_B2_AUX($fp)
	# Cargo el 2do byte del buffer en v0.
	lbu	v0,OFFSET_B2($fp)
	# Hago un shift left de 4 posiciones.
	srl	v0,v0,4
	# Cargo en v1 el resultado(byte) del shift right 2.
	lbu	v1,OFFSET_B2_AUX($fp)
	# Hago un 'or' entre v1 y v0 para obtener el 2 indice de la tabla.
	or	v0,v1,v0
	#(*) Guardo en stack frame(12) el resultado del 'or' anterior.
	sb	v0,OFFSET_B2_AUX($fp)
	# Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	# Cargo en v1 la dirección del output + 1(1byte).
	addu	v1,v0,1
	# Cargo en v0 el ultimo resultado del shift(*)
	lbu	v0,OFFSET_B2_AUX($fp)
	# Cargo en v0 el caracter(byte) de la tabla encoding(encoding_table)
	lbu	v0,encoding_table(v0)
	# Salvo en el output array(output[1]) el valor del encoding_table
	sb	v0,0(v1)
	# Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	# Sumo 2 a la dirección del output(output[2]).
	# Me desplazo dentro del output array.
	addu	v1,v0,2
	# Cargo en v0 el caracter ascii 61('=').
	li	v0,EQUAL_CHAR			# 0x3d
	# Salvo en el output array(output[2]) el valor '='.
	sb	v0,0(v1)
	# Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	# Sumo 3 a la dirección del output(output[3]).
	# Me desplazo dentro del output array.
	addu	v1,v0,3
	# Cargo en v0 el caracter ascii 61('=').
	li	v0,EQUAL_CHAR			# 0x3d
	# Salvo en el output array(output[3]) el valor '='.
	sb	v0,0(v1)
	# Cargo en v1 el parametro length.
	lw	v1,OFFSET_LENGTH_ENCODE($fp)
	# Cargo en v0 el valor 3.
	li	v0,3			# 0x3
	# Si el length == 3 salto a buffer_size_2.	
	bne	v1,v0,buffer_size_2
	# Si el tamanio del buffer es 3 continuo NO salto.
	# Cargo en v0 el 3er byte del buffer.
	lbu	v0,OFFSET_B3($fp)
	# Hago un shift right de 6.
	srl	v0,v0,6
	# Guardo el nuevo byte en el stack frame.
	sb	v0,OFFSET_B3_AUX($fp)
	# Cargo el 2do byte del buffer en v0.
	lbu	v0,OFFSET_B2($fp)
	# Hago un shift left de 4.
	sll	v0,v0,4
	# Guardo en el stack frame(14) el nuevo valor.
	sb	v0,OFFSET_B3_AUX_2($fp)
	# Cargo en v0 el byte shifteado sin signo.
	lbu	v0,OFFSET_B3_AUX_2($fp)
	# Hago un shift rigth de 2.
	srl	v0,v0,2
	# Guardo en el stack frame(14) el valor shifteado.
	sb	v0,OFFSET_B3_AUX_2($fp)
	# Cargo en v1 el valor del SF(13)
	lbu	v1,OFFSET_B3_AUX($fp)
	# Idem en v0(13).
	lbu	v0,OFFSET_B3_AUX_2($fp)
	# Hago un 'or' y almaceno en v0.
	or	v0,v1,v0
	# Guardo en el stack frame(13) el resultado del 'or'.
	sb	v0,OFFSET_B3_AUX($fp)
	# Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	# Me desplazo por el vector 'output' en 2 posiciones(output[2]).
	addu	v1,v0,2
	# Cargo en v0 el resultado del 'or' anterior.
	lbu	v0,OFFSET_B3_AUX($fp)
	# Busco en la tabla de encoding el caracter que corresponde.
	# Luego cargo el byte en v0.
	lbu	v0,encoding_table(v0)
	# Guardo el valor recuperado de la tabla encoding_table en el output[2].
	sb	v0,0(v1)
	# Cargo en v0 el 3er byte del buffer.
	lbu	v0,OFFSET_B3($fp)
	# Hago un shift left de 2.
	sll	v0,v0,2
	# Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_B4_AUX($fp)
	# Cargo el byte sin signo shifteado.
	lbu	v0,OFFSET_B4_AUX($fp)
	# Hago un shift rigth de 2.
	srl	v0,v0,2
	# Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_B4_AUX($fp)
	# Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	# Sumo 3 a la dirección del output(output[3]).
	# Me desplazo dentro del output array.
	addu	v1,v0,3
	# Cargo en v0 el ultimo valor shifteado guardado.
	lbu	v0,OFFSET_B4_AUX($fp)
	# Busco en la tabla de encoding el caracter que corresponde.
	# Luego cargo el byte en v0.
	lbu	v0,encoding_table(v0)
	# Guardo el valor recuperado de la tabla encoding_table en el output[3].
	sb	v0,0(v1)
	# Salto a return_encode
	b	return_encode
buffer_size_2:
	# Cargo en v1 el valor del parámetro length.
	lw	v1,OFFSET_LENGTH_ENCODE($fp)
	# Cargo en v0 el valor 2.
	li	v0,2			# 0x2
	# Si length != 2 salgo de la función.	
	bne	v1,v0,return_encode
	# Cargo en v0 el 3er byte del buffer.
	lbu	v0,OFFSET_B3($fp)
	# Hago un shift right de 6.
	srl	v0,v0,6
	# Guardo en el stack frame el ultimo valor shifteado. 
	sb	v0,OFFSET_B4_AUX($fp)
	# Cargo el 2do byte del buffer en v0.
	lbu	v0,OFFSET_B2($fp)
	# Hago un shift left de 4 posiciones.
	sll	v0,v0,4
	# Guardo en el stack frame nuevo valor shifteado.
	sb	v0,OFFSET_B3_AUX_2($fp)
	# Cargo en v0 el byte shifteado sin signo.
	lbu	v0,OFFSET_B3_AUX_2($fp)
	# Hago un shift right de 2 posiciones.
	srl	v0,v0,2
	# Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_B3_AUX_2($fp)
	# Cargo en v1 uno de los valores shiftedos(b3aux).
	lbu	v1,OFFSET_B4_AUX($fp)
	# Cargo en v0 uno de los valores shiftedos(b3aux2).
	lbu	v0,OFFSET_B3_AUX_2($fp)
	# Hago un 'or' entre b3aux y b3aux2.
	or	v0,v1,v0
	# Guardo en el stack frame el resutado del 'or'.
	sb	v0,OFFSET_B4_AUX($fp)
	# Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	# Me desplazo dentro del output array y lo guardo en v1.
	addu	v1,v0,2
	# Cargo en v0 ultimo resultado del 'or'
	lbu	v0,OFFSET_B4_AUX($fp)
	# Busco en la tabla de encoding el caracter que corresponde.
	# Luego cargo el byte en v0.
	lbu	v0,encoding_table(v0)
	# Guardo el valor recuperado de la tabla encoding_table en el output[2].
	sb	v0,0(v1)
return_encode:
	move	sp,$fp
	lw	$fp,OFFSET_FP_ENCODE(sp)
	# destruyo stack frame
	addu	sp,sp,STACK_FRAME_ENCODE
	j	ra
	.end	Encode
	#.size	Encode, .-Encode
	#.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
