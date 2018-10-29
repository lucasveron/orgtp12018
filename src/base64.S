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

#define RETURNO_OK 1
#define DECODE_ERROR   100
#define SIZE_DECODE_CHAR 4

#define SHIFT_2 2
#define SHIFT_4 4
#define SHIFT_6 6

#define EQUAL_CHAR 61

#define STACK_FRAME_DECODECHAR 28

#define OFFSET_RA_DECODECHAR 24
#define OFFSET_FP_DECODECHAR 20
#define OFFSET_GP_DECODECHAR 16
#define OFFSET_RETURN_DECODECHAR 8
#define OFFSET_I_DECODECHAR 4
#define OFFSET_CHARACTER_DECODECHAR 0

#define STACK_FRAME_DECODE 32//64

#define OFFSET_BUFFER_OUTPUT_ENCODE 36//68
#define OFFSET_BUFFER_INPUT_ENCODE 32//64
#define OFFSET_RA_DECODE 24//28//60
#define OFFSET_FP_DECODE 20//24//56
#define OFFSET_GP_DECODE 16//20//52
//#define OFFSET_S0_DECODE 16//48
#define OFFSET_CHAR1_AUX_ENCODE 13//37
#define OFFSET_CHAR0_AUX_ENCODE 12//36
#define OFFSET_I_DECODE 8//32
#define OFFSET_CHARS3_ENCODE 7//27
#define OFFSET_CHARS2_ENCODE 6//26
#define OFFSET_CHARS1_ENCODE 5//25
#define OFFSET_CHARS0_ENCODE 4//24
#define OFFSET_RETURN_ENCODE 0//20

	.data
	.align	2
sep:	.ascii 	"\n"
pad: 	.ascii	"="
	.globl errmsg
errmsg:
	.word base64_ok, base64_err1, base64_err2, base64_err3
	.size errmsg, 16
base64_ok:
	.asciiz "OK"
base64_err1:
	.asciiz "I/O Error"
base64_err2:
	.asciiz "File no es multiplo de 4"
base64_err3: 
	.asciiz "File contiene caracteres invalidos"
	.text
	.align	2
	.globl	base64_encode
	.ent	base64_encode
base64_encode:
	// debugging info: descripcion del stack frame
	.frame	$fp, 40, ra	// $fp: registro usado como frame pointer
				// 32: tamañodel stack frame
				// ra: registro que almacena el return address
	// bloque para codigo PIC
	.set	noreorder	// apaga reordenamiento de instrucciones
	.cpload t9		// directiva usada para codigo PIC
	.set	reorder		// enciende reordenamiento de instrucciones
	// creo stack frame
	subu	sp, sp, 40	// 4 (SRA) + 2 (LTA) + 4 (ABA)
	// directiva para codigo PIC
	.cprestore 24		// inserta aqui "sw gp, 24(sp)",
				// mas "lw gp, 24(sp)" luego de cada jal.
	// salvado de callee-saved regs en SRA	
	sw	$fp, 28(sp)
	sw	ra, 32(sp)
	// de aqui al fin de la funcion uso $fp en lugar de sp.
	move	$fp, sp
	// salvo 1er arg (siempre)
	sw	a0, 40($fp)	// a0 contiene file input
	sw	a1, 44($fp)	// a1 contiene file output 
	li	s1, 0		// count = 0
	
	//Limpio input para read
base64_encode_loop:
	sw	zero, 20($fp)	//input = 0
	
	//Leo archivo
	lw	a0, 40($fp)
	addi	a1, $fp, 20
	li	a2, 3
	li	v0, SYS_read
	syscall
	beqz	v0, base64_encode_return_ok	//Si no lei nada finalizo 
	blt	v0, 0, base64_encode_io_error
	//Paso parametros y llamo a Encode
	addi	a0, $fp, 20
	move	a1, v0
	addi	a2, $fp, 16
	la 	t9, Encode
	jal 	ra, t9
				
	//Grabo en file
	lw 	a0, 44($fp)	// File descriptor out
	addi	a1, $fp, 16	// Apunto a buffer out
	li	a2, 4		// length = 4
	li	v0, SYS_write
	syscall   
	addi s1, s1, 1		// count++
	bne s1, 18, base64_encode_loop // Si count = 18 agrego un salto
	lw 	a0, 44($fp)	// file out
	la	a1, sep		// sep = '\n'
	li	a2, 1		// length = 4
	li	v0, SYS_write
	syscall   
	li	s1, 0
	j base64_encode_loop
		
base64_encode_return_ok:	// return;
	li	v0, 0
	j base64_encode_return
base64_encode_io_error:
	li	v0, 1
	// restauro callee-saved regs
base64_encode_return:
	lw	gp, 24(sp)
	lw	$fp, 28(sp)
	lw	ra, 32(sp)
	// destruyo stack frame
	addu	sp, sp, 40
	// vuelvo a funcion llamante
	jr	ra
	.end	base64_encode
	.size	base64_encode, .-base64_encode

	.globl	base64_decode
	.ent	base64_decode
base64_decode:
	// debugging info: descripcion del stack frame
	.frame	$fp, 56, ra	// $fp: registro usado como frame pointer
				// 56: tamañodel stack frame
				// ra: registro que almacena el return address
	// bloque para codigo PIC
	.set	noreorder	// apaga reordenamiento de instrucciones
	.cpload t9		// directiva usada para codigo PIC
	.set	reorder		// enciende reordenamiento de instrucciones
	// creo stack frame
	subu	sp, sp, 56	// 8 (SRA) + 2 (LTA) + 4 (ABA)
	// directiva para codigo PIC
	.cprestore 44		// inserta aqui "sw gp, 24(sp)",
				// mas "lw gp, 24(sp)" luego de cada jal.
	// salvado de callee-saved regs en SRA	
	sw	$fp, 48(sp)
	sw	ra, 52(sp)
	sw	s1, 24(sp)
	sw	s2, 28(sp)
	sw	s3, 32(sp)
	sw	s4, 36(sp)
	sw	s5, 40(sp)
	// de aqui al fin de la funcion uso $fp en lugar de sp.
	move	$fp, sp
	// salvo 1er arg (siempre)
	sw	a0, 56($fp)	// a0 contiene file input
	sw	a1, 60($fp)	// a1 contiene file output 
	li	s1, 0		// count = 0
	la	s5, pad
	lbu	s5, 0(s5)
	//Limpio input para read
base64_decode_loop:
	sw	zero, 20($fp)	//input = 0
	
	//Leo archivo
	lw	a0, 56($fp)
	addi	a1, $fp, 20
	li	a2, 4
	li	v0, SYS_read
	syscall
	beqz	v0, base64_decode_return_ok	//Si no lei nada finalizo
	blt	v0, 0, base64_decode_ioerror
	blt	v0, 4, base64_decode_nomult 
	//Controlo si hay padding
	li	s3, 0				//s3 = cant de padding a borrar
	lbu	s2, 23($fp)			//s2 aux control padding
	bne	s2, s5, ctl1
	addi 	s3, s3, 1
ctl1:	
	lbu	s2, 22($fp)			//s2 aux control padding
	bne	s2, s5, ctl2
	addi 	s3, s3, 1
ctl2:	
	//Controlo salto de linea
	addi s1, s1, 1		// count++
	bne s1, 18, not_sep 	// Si count = 18 elimino un caracter
	lw 	a0, 56($fp)	// file in
	addi	a1, $fp, 16	// grabo en out buffer, luego se pisa
	li	a2, 1		// length = 1
	li	v0, SYS_read
	syscall   
	li	s1, 0
	//Paso parametros y llamo a Decode
not_sep: 
	addi	a0, $fp, 20
	addi	a1, $fp, 16
	la 	t9, Decode
	jal 	ra, t9
	
	//Chequeo error
	beq	v0, DECODE_ERROR, base64_decode_decode_err	
			
	//Grabo en file
	lw 	a0, 60($fp)	// File descriptor out
	addi	a1, $fp, 16	// Apunto a buffer out
	li	s4, 3
	subu	a2, s4, s3	// a2 = 3 - cant de padding 
	li	v0, SYS_write
	syscall   
	j base64_decode_loop
base64_decode_return_ok:
	li v0, 0
	j base64_decode_return
base64_decode_ioerror:
	li v0, 1
	j base64_decode_return
base64_decode_nomult:		
	li v0, 2
	j base64_decode_return
base64_decode_decode_err:		
	li v0, 3
base64_decode_return:	// return;
	// restauro callee-saved regs
	lw	gp, 44(sp)
	lw	$fp, 48(sp)
	lw	ra, 52(sp)
	lw	s1, 24(sp)
	lw	s2, 28(sp)
	lw	s3, 32(sp)
	lw	s4, 36(sp)
	lw	s5, 40(sp)
	// destruyo stack frame
	addu	sp, sp, 56
	// vuelvo a funcion llamante
	jr	ra
	.end	base64_decode
	.size	base64_decode, .-base64_decode

	//.file	1 "encode.c"
	//.section .mdebug.abi32
	//.previous
	//.abicalls
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

	.type	encoding_table_size, @object
	.size	encoding_table_size, 4
encoding_table_size:
	.word	64

	.text
	.align	2
	.globl	Encode
	.ent	Encode

	//////////////	Función Encode //////////////

Encode:
	.frame	$fp,STACK_FRAME_ENCODE,ra		// vars= 8, regs= 2/0, args= 0, extra= 8
	//.mask	0x50000000,-4
	//.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder

	// Creación del stack frame
	subu	sp,sp,STACK_FRAME_ENCODE

	.cprestore 0
	sw	$fp,OFFSET_FP_ENCODE(sp)
	sw	gp,OFFSET_GP_ENCODE(sp)
	
	// De aquí al final de la función uso $fp en lugar de sp.
	move	$fp,sp
	
	// Guardo el primer parámetro *buffer
	sw	a0,OFFSET_BUFFER_ENCODE($fp)
	// Guardo el segundo parámetro 'length'(cantidad de caracteres)
	sw	a1,OFFSET_LENGTH_ENCODE($fp)
	// Guardo el puntero al array de salida(output)
	sw	a2,OFFSET_OUTPUT_ENCODE($fp)
	
	// Cargo en v0 el puntero al buffer.
	lw	v0,OFFSET_BUFFER_ENCODE($fp)
	// Cargo en v0 el 1er byte del buffer.
	lbu	v0,0(v0)
	// Guardo el 1er byte en el stack frame
	sb	v0,OFFSET_B1($fp)
	// Cargo nuevamente la dirección del buffer.
	lw	v0,OFFSET_BUFFER_ENCODE($fp)
	// Aumento en 1(1 byte) la dirección del buffer.
	// Me muevo por el array del buffer.
	addu	v0,v0,1
	// Cargo el 2do byte del buffer.
	lbu	v0,0(v0)
	// Guardo el 2do byte en el stack frame.
	sb	v0,OFFSET_B2($fp)
	// Cargo nuevamente la dirección del buffer.
	lw	v0,OFFSET_BUFFER_ENCODE($fp)
	// Aumento en 2(2 byte) la dirección del buffer.
	// Me muevo por el array del buffer.
	addu	v0,v0,2
	// Cargo el 2do byte del buffer.
	lbu	v0,0(v0)
	// Guardo el 3er byte en stack frame.
	sb	v0,OFFSET_B3($fp)
	// Cargo en v0 el 1er byte.
	lbu	v0,OFFSET_B1($fp)
	// Muevo 2 'posiciones' hacia la derecha(shift 2).
	srl	v0,v0,2
	// Guardo el nuevo byte en una variable auxiliar.
	sb	v0,OFFSET_B1_AUX($fp)
	// Cargo en v1 el puntero al output.
	lw	v1,OFFSET_OUTPUT_ENCODE($fp)
	// Cargo en v0 el byte shifteado.
	lbu	v0,OFFSET_B1_AUX($fp)
	// Cargo en v0 el caracter(byte) de la tabla encoding(encoding_table)
	lbu	v0,encoding_table(v0)
	// Cargo en v0 el 1er byte de la dirección del output.
	sb	v0,0(v1)
	// Cargo en v0 el 1er byte del buffer nuevamente.
	lbu	v0,OFFSET_B1($fp)
	// Muevo 6 'posiciones' hacia la izquierda(shift 6). 
	sll	v0,v0,6
	// Guardo el resultado del shift en el Stack Frame.
	sb	v0,OFFSET_B2_AUX($fp)
	// Cargo el byte sin signo shifteado.
	lbu	v0,OFFSET_B2_AUX($fp)
	// Muevo 2 'posiciones' hacia la derecha(shift 2).
	srl	v0,v0,2
	// Guardo el nuevo resultado del shift en el Stack Frame.
	sb	v0,OFFSET_B2_AUX($fp)
	// Cargo el 2do byte del buffer en v0.
	lbu	v0,OFFSET_B2($fp)
	// Hago un shift left de 4 posiciones.
	srl	v0,v0,4
	// Cargo en v1 el resultado(byte) del shift right 2.
	lbu	v1,OFFSET_B2_AUX($fp)
	// Hago un 'or' entre v1 y v0 para obtener el 2 indice de la tabla.
	or	v0,v1,v0
	//(*) Guardo en stack frame(12) el resultado del 'or' anterior.
	sb	v0,OFFSET_B2_AUX($fp)
	// Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	// Cargo en v1 la dirección del output + 1(1byte).
	addu	v1,v0,1
	// Cargo en v0 el ultimo resultado del shift(*)
	lbu	v0,OFFSET_B2_AUX($fp)
	// Cargo en v0 el caracter(byte) de la tabla encoding(encoding_table)
	lbu	v0,encoding_table(v0)
	// Salvo en el output array(output[1]) el valor del encoding_table
	sb	v0,0(v1)
	// Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	// Sumo 2 a la dirección del output(output[2]).
	// Me desplazo dentro del output array.
	addu	v1,v0,2
	// Cargo en v0 el caracter ascii 61('=').
	li	v0,EQUAL_CHAR			// 0x3d
	// Salvo en el output array(output[2]) el valor '='.
	sb	v0,0(v1)
	// Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	// Sumo 3 a la dirección del output(output[3]).
	// Me desplazo dentro del output array.
	addu	v1,v0,3
	// Cargo en v0 el caracter ascii 61('=').
	li	v0,EQUAL_CHAR			// 0x3d
	// Salvo en el output array(output[3]) el valor '='.
	sb	v0,0(v1)
	// Cargo en v1 el parametro length.
	lw	v1,OFFSET_LENGTH_ENCODE($fp)
	// Cargo en v0 el valor 3.
	li	v0,3			// 0x3
	// Si el length == 3 salto a buffer_size_2.	
	bne	v1,v0,buffer_size_2
	// Si el tamanio del buffer es 3 continuo NO salto.
	// Cargo en v0 el 3er byte del buffer.
	lbu	v0,OFFSET_B3($fp)
	// Hago un shift right de 6.
	srl	v0,v0,6
	// Guardo el nuevo byte en el stack frame.
	sb	v0,OFFSET_B3_AUX($fp)
	// Cargo el 2do byte del buffer en v0.
	lbu	v0,OFFSET_B2($fp)
	// Hago un shift left de 4.
	sll	v0,v0,4
	// Guardo en el stack frame(14) el nuevo valor.
	sb	v0,OFFSET_B3_AUX_2($fp)
	// Cargo en v0 el byte shifteado sin signo.
	lbu	v0,OFFSET_B3_AUX_2($fp)
	// Hago un shift rigth de 2.
	srl	v0,v0,2
	// Guardo en el stack frame(14) el valor shifteado.
	sb	v0,OFFSET_B3_AUX_2($fp)
	// Cargo en v1 el valor del SF(13)
	lbu	v1,OFFSET_B3_AUX($fp)
	// Idem en v0(13).
	lbu	v0,OFFSET_B3_AUX_2($fp)
	// Hago un 'or' y almaceno en v0.
	or	v0,v1,v0
	// Guardo en el stack frame(13) el resultado del 'or'.
	sb	v0,OFFSET_B3_AUX($fp)
	// Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	// Me desplazo por el vector 'output' en 2 posiciones(output[2]).
	addu	v1,v0,2
	// Cargo en v0 el resultado del 'or' anterior.
	lbu	v0,OFFSET_B3_AUX($fp)
	// Busco en la tabla de encoding el caracter que corresponde.
	// Luego cargo el byte en v0.
	lbu	v0,encoding_table(v0)
	// Guardo el valor recuperado de la tabla encoding_table en el output[2].
	sb	v0,0(v1)
	// Cargo en v0 el 3er byte del buffer.
	lbu	v0,OFFSET_B3($fp)
	// Hago un shift left de 2.
	sll	v0,v0,2
	// Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_B4_AUX($fp)
	// Cargo el byte sin signo shifteado.
	lbu	v0,OFFSET_B4_AUX($fp)
	// Hago un shift rigth de 2.
	srl	v0,v0,2
	// Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_B4_AUX($fp)
	// Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	// Sumo 3 a la dirección del output(output[3]).
	// Me desplazo dentro del output array.
	addu	v1,v0,3
	// Cargo en v0 el ultimo valor shifteado guardado.
	lbu	v0,OFFSET_B4_AUX($fp)
	// Busco en la tabla de encoding el caracter que corresponde.
	// Luego cargo el byte en v0.
	lbu	v0,encoding_table(v0)
	// Guardo el valor recuperado de la tabla encoding_table en el output[3].
	sb	v0,0(v1)
	// Salto a return_encode
	b	return_encode
buffer_size_2:
	// Cargo en v1 el valor del parámetro length.
	lw	v1,OFFSET_LENGTH_ENCODE($fp)
	// Cargo en v0 el valor 2.
	li	v0,2			// 0x2
	// Si length != 2 salgo de la función.	
	bne	v1,v0,return_encode
	// Cargo en v0 el 3er byte del buffer.
	lbu	v0,OFFSET_B3($fp)
	// Hago un shift right de 6.
	srl	v0,v0,6
	// Guardo en el stack frame el ultimo valor shifteado. 
	sb	v0,OFFSET_B4_AUX($fp)
	// Cargo el 2do byte del buffer en v0.
	lbu	v0,OFFSET_B2($fp)
	// Hago un shift left de 4 posiciones.
	sll	v0,v0,4
	// Guardo en el stack frame nuevo valor shifteado.
	sb	v0,OFFSET_B3_AUX_2($fp)
	// Cargo en v0 el byte shifteado sin signo.
	lbu	v0,OFFSET_B3_AUX_2($fp)
	// Hago un shift right de 2 posiciones.
	srl	v0,v0,2
	// Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_B3_AUX_2($fp)
	// Cargo en v1 uno de los valores shiftedos(b3aux).
	lbu	v1,OFFSET_B4_AUX($fp)
	// Cargo en v0 uno de los valores shiftedos(b3aux2).
	lbu	v0,OFFSET_B3_AUX_2($fp)
	// Hago un 'or' entre b3aux y b3aux2.
	or	v0,v1,v0
	// Guardo en el stack frame el resutado del 'or'.
	sb	v0,OFFSET_B4_AUX($fp)
	// Cargo en v0 el puntero al output.
	lw	v0,OFFSET_OUTPUT_ENCODE($fp)
	// Me desplazo dentro del output array y lo guardo en v1.
	addu	v1,v0,2
	// Cargo en v0 ultimo resultado del 'or'
	lbu	v0,OFFSET_B4_AUX($fp)
	// Busco en la tabla de encoding el caracter que corresponde.
	// Luego cargo el byte en v0.
	lbu	v0,encoding_table(v0)
	// Guardo el valor recuperado de la tabla encoding_table en el output[2].
	sb	v0,0(v1)
return_encode:
	move	sp,$fp
	lw	$fp,OFFSET_FP_ENCODE(sp)
	// destruyo stack frame
	addu	sp,sp,STACK_FRAME_ENCODE
	j	ra
	.end	Encode
	//.size	Encode, .-Encode

	.globl	DecodeChar
	.ent	DecodeChar
	
	////////////// Begin Función DecodeChar //////////////

DecodeChar:
	// Reservo espacio para el stack frame de STACK_FRAME_DECODECHAR bytes
	.frame	$fp,STACK_FRAME_DECODECHAR,ra		// vars= 8, regs= 2/0, args= 0, extra= 8
	//.mask	0x50000000,-4
	//.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder
	
	// Creación del stack frame STACK_FRAME_DECODECHAR
	subu	sp,sp,STACK_FRAME_DECODECHAR
	.cprestore 0
	
	// Guardo fp y gp en el stack frame
	sw      ra,OFFSET_RA_DECODECHAR(sp)
	sw	$fp,OFFSET_FP_DECODECHAR(sp)
	sw	gp,OFFSET_GP_DECODECHAR(sp)
	// De aquí al final de la función uso $fp en lugar de sp.
	move	$fp,sp
	
	// Guardo en v0 el parámetro recibido: 'character'.
	move	v0,a0
	// Guardo en el stack frame 'character'.
	sb	v0,OFFSET_CHARACTER_DECODECHAR($fp)
	// Guardo en un '0' en el stack frame.
	// Inicializo la variable 'i'.
	sb	zero,OFFSET_I_DECODECHAR($fp)
condition_loop:	
	// Cargo en v0 el byte guardado anteriormente(0 o el nuevo valor de 'i').
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	// Cargo en v1 el size del encoding_table(64).
	lw	v1,encoding_table_size
	// Si (i < encoding_table_size), guardo TRUE en v0, sino FALSE.
	slt	v0,v0,v1
	// Salto a condition_if si v0 != 0.
	bne	v0,zero,condition_if
	// Brancheo a condition_if_equal
	b	condition_if_equal
condition_if:	
	// Cargo en v0 el valor de 'i'.
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	// Cargo en v1 el byte contenido en encoding_table según el valor de 'i'.
	// encoding_table[i]
	lbu	v1,encoding_table(v0)
	// Cargo en v0 'character'.
	lb	v0,OFFSET_CHARACTER_DECODECHAR($fp)
	// Salto a increase_index si el valor recuperado del vector encoding_table
	// es distinto al valor pasado por parámetro(character).
	bne	v1,v0,increase_index
	// Cargo en v0 nuevamente el valor de 'i'.
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	
	// Guardo en el stack frame(12) el valor de 'i'
	//sw	v0,12($fp) //VER
	sw v0,OFFSET_RETURN_DECODECHAR($fp)

	// Brancheo a return_decode_index_or_zero
	b	return_decode_index_or_zero
increase_index:
	// Cargo en v0 nuevamente el valor de 'i'.
	lbu	v0,OFFSET_I_DECODECHAR($fp)
	// Sumo en 1 el valor de 'i'(i++).
	addu	v0,v0,1
	// Guardo el valor modificado en el stack frame.
	sb	v0,OFFSET_I_DECODECHAR($fp)
	// Salto a condition_loop
	b	condition_loop
condition_if_equal:
	// Cargo en v1 el byte(char) recibido como parámetro.
	// parametro: character.
	lb	v1,OFFSET_CHARACTER_DECODECHAR($fp)
	// Cargo en v0 el inmediato EQUAL_CHAR=61(corresponde a el char '=').
	li	v0,EQUAL_CHAR			// 0x3d
	// Salto a return_decode_error si el char recibido por parámetro no es igual a '='.
	bne	v1,v0,return_decode_error
	// Guardo un 0(DECODE_EQUAL) en el stack frame(12).
	sw	zero,OFFSET_RETURN_DECODECHAR($fp)
	// Salto a return_decode_index_or_zero.
	b	return_decode_index_or_zero
return_decode_error:
	// Cargo en v0 el inmediato DECODE_ERROR=100
	li	v0,DECODE_ERROR			// 0x64
	// Guardo el DECODE_ERROR en el stack frame.
	sw	v0,OFFSET_RETURN_DECODECHAR($fp)
return_decode_index_or_zero:
	// Cargo en v0 el valor retornado por DecodeChar
	lw	v0,OFFSET_RETURN_DECODECHAR($fp)
	
	move	sp,$fp
	// Restauro fp
	lw	$fp,OFFSET_FP_DECODECHAR(sp)
	// Restauro ra
	lw      ra,OFFSET_RA_DECODECHAR(sp)
	// Destruyo el stack frame
	addu	sp,sp,STACK_FRAME_DECODECHAR
	// Regreso el control a la función llamante.
	j	ra
	.end	DecodeChar
	//.size	DecodeChar, .-DecodeChar

	//////////////	End Función DecodeChar //////////////

	//////////////	Begin Función Decode //////////////

	.align	2
	.globl	Decode
	.ent	Decode
Decode:
	.frame	$fp,STACK_FRAME_DECODE,ra		// vars= 24, regs= 4/0, args= 16, extra= 8
	//.mask	0xd0010000,-4
	//.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder
	
	// Creación del stack frame
	subu	sp,sp,STACK_FRAME_DECODE
	.cprestore 16
	
	sw	ra,OFFSET_RA_DECODE(sp)
	sw	$fp,OFFSET_FP_DECODE(sp)
	sw	gp,OFFSET_GP_DECODE(sp)
	//sw	s0,OFFSET_S0_DECODE(sp)

	// De aquí al final de la función uso $fp en lugar de sp.
	move	$fp,sp
	
	// Guardo en el stack frame los parámetros recibidos.
	// a0=puntero a buffer_input
	sw	a0,OFFSET_BUFFER_INPUT_ENCODE($fp)
	// Guardo en el stack frame los parámetros recibidos.
	// a1=puntero a buffer_output
	sw	a1,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	// Guardo un 0 en el stack frame(OFFSET_I_DECODE). Inicializo 'i'.
	sw	zero,OFFSET_I_DECODE($fp)
loop_decode_char:
	// Cargo en v0 el valor de 'i' guardado en el stack frame.
	lw	v0,OFFSET_I_DECODE($fp)
	// Si (i < SIZE_DECODE_CHAR), guardo TRUE en v0, sino FALSE.
	sltu	v0,v0,SIZE_DECODE_CHAR
	// Salto a if_decode_char si sigo dentro del bucle.
	bne	v0,zero,if_decode_char
	// Salto a main_shift
	b	main_shift
if_decode_char:
	// Cargo en v1 el valor de 'i'.
	lw	v1,OFFSET_I_DECODE($fp)
	// Cargo en v0 el valor de fp + OFFSET_CHARS0_ENCODE ???
	addu	v0,$fp,OFFSET_CHARS0_ENCODE
	// Cargo en s0 el valor de buf_input[i]
	addu	s0,v0,v1
	// Cargo en v1 el puntero a buf_input
	lw	v1,OFFSET_BUFFER_INPUT_ENCODE($fp)
	// Cargo en v0 el valor de 'i'.
	lw	v0,OFFSET_I_DECODE($fp)
	// Me desplazo por el vector(buf_input[i])
	addu	v0,v1,v0
	// Cargo en v0 el valor del buf_input[i](1 byte).
	lb	v0,0(v0)
	// Asigna el valor del byte a a0 antes de llamar a la función.
	move	a0,v0
	// Carga en t9 la direccion de la funcion DecodeChar.
	la	t9,DecodeChar
	// Hace el llamado a la función.
	jal	ra,t9
	// Guardo en s0 el resultado de la función.
	// El valor regresa en el registro v0
	sb	v0,0(s0)
	// Cargo en v1 el valor de 'i'.
	lw	v1,OFFSET_I_DECODE($fp)
	// Cargo en v0 el valor de fp + OFFSET_CHARS_ENCODE ???
	addu	v0,$fp,OFFSET_CHARS0_ENCODE
	// Cargo en v0 el valor de chars[i](direccion).
	addu	v0,v0,v1
	// Cargo en v1 el byte apuntado.
	lbu	v1,0(v0)
	// Cargo en v0 el DECODE_ERROR
	li	v0,DECODE_ERROR			// 0x64
	// Si chars[i] != DECODE_ERROR salto a increase_index_decode
	bne	v1,v0,increase_index_decode
	// Guarda en el stack frame un 0.
	sw	zero,OFFSET_RETURN_ENCODE($fp)
	// Si chars[i] == DECODE_ERROR retorno un 0.
	b	return_zero
increase_index_decode:
	// Cargo en v0 el valor de 'i'.
	lw	v0,OFFSET_I_DECODE($fp)
	// Sumo en 1 el valor de 'i'(i++). 
	addu	v0,v0,1
	// Guardo el valor modificado en el stack frame.
	sw	v0,OFFSET_I_DECODE($fp)
	// Salto a loop_decode_char
	b	loop_decode_char
main_shift:	
	// Cargo en v0 la dirección de chars[0]
	lbu	v0,OFFSET_CHARS0_ENCODE($fp)
	// Hago un shift left logical de SHIFT_2 y lo asigno a v0.
	sll	v0,v0,SHIFT_2
	// Guardo el valor en el stack frame.
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Cargo el valor de chars[1] en v0.
	lbu	v0,OFFSET_CHARS1_ENCODE($fp)
	// Hago un shift left logical de SHIFT_2 y lo asigno a v0.
	srl	v0,v0,SHIFT_4
	// Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	// Cargo en v1 char1_aux(chars[0] luego de ser shifteado).
	lbu	v1,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Cargo en v0 char2_aux(chars[1] luego de ser shifteado).
	lbu	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	// Hago un or de v1 y v0 y lo asigno a v0.
	or	v0,v1,v0
	// Guardo en valor en el stack frame.
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Cargo en v1 el puntero al buffer_output.
	lw	v1,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	// Cargo en v0 char1_aux(chars[0] luego de ser shifteado).
	lbu	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Guardo en el vector buffer_output el valor de char1_aux.
	sb	v0,0(v1)
	// Cargo el valor de chars[1] en v0.
	lbu	v0,OFFSET_CHARS1_ENCODE($fp)
	// Hago un shift left de 4 posiciones y lo guardo en v0.
	sll	v0,v0,SHIFT_4
	// Guardo en el stack frame el valor shifteado.
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Cargo en v0 chars[2].
	lbu	v0,OFFSET_CHARS2_ENCODE($fp)
	// Hago un shift rigth de 2 de chars[2] y lo guardo en v0.
	srl	v0,v0,SHIFT_2
	// Guardo en stack frame el valor shifteado.
	sb	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	// Cargo en v1 y v0 los valores shifteados anteriormente.
	lbu	v1,OFFSET_CHAR1_AUX_ENCODE($fp)
	lbu	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Hago un or de v1 y v0 y lo asigno a v0.
	or	v0,v1,v0
	// Vuelvo a guardar en el stack frame el resultado del or.
	// (**)
	sb	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	// Cargo en v0 el puntero al buffer_output.
	lw	v0,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	// Sumo 1 al puntero para desplazarme dentro del vector.
	// Luego asigno el resultado a v1.
	addu	v1,v0,1
	// Cargo en v0 el resultado de (**).
	lbu	v0,OFFSET_CHAR1_AUX_ENCODE($fp)
	// Guardo en el vector buffer_output el valor (**).
	sb	v0,0(v1)
	// Cargo en v0 chars[2]
	lbu	v0,OFFSET_CHARS2_ENCODE($fp)
	// Hago un shift left de 6.
	sll	v0,v0,SHIFT_6
	// Guardo en el stack frame el valor shifteado.
	// (***)
	sb	v0,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Cargo en v0 el puntero al buffer_output.
	lw	v0,OFFSET_BUFFER_OUTPUT_ENCODE($fp)
	// Sumo 2 al puntero para desplazarme dentro del vector buffer_output.
	// Luego asigno el resultado a a0.
	addu	a0,v0,2
	// Cargo en v1 el ultimo valor shifteado (***).
	lbu	v1,OFFSET_CHAR0_AUX_ENCODE($fp)
	// Cargo en v0 chars[3]
	lbu	v0,OFFSET_CHARS3_ENCODE($fp)
	// Hago un or de v1 y v0 y lo asigno a v0.
	or	v0,v1,v0
	// Guardo en el vector buffer_output el resultado del or. 
	sb	v0,0(a0)
	// Cargo en v0 el inmediato 1(RETURNO_OK).
	li	v0,RETURNO_OK			// 0x1
	// Guardo en el stack frame el valor de retorno.
	sw	v0,OFFSET_RETURN_ENCODE($fp)
return_zero:
	// Cargo en v0 el valor salvado en el stack frame(0).
	lw	v0,OFFSET_RETURN_ENCODE($fp)
	move	sp,$fp

	// Restauro ra,fp y gp.
	lw	ra,OFFSET_RA_DECODE(sp)
	lw	$fp,OFFSET_FP_DECODE(sp)
	//lw	s0,OFFSET_S0_DECODE(sp)

	// Destruyo el stack frame.
	addu	sp,sp,STACK_FRAME_DECODE
	// Devuelvo el control a la función llamante.
	j	ra

	.end	Decode
	.size	Decode, .-Decode

	
