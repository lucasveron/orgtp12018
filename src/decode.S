#include <mips/regdef.h>
#include <sys/syscall.h>
	
	.file	1 "decode.c"
	//.section .mdebug.abi32
	//.previous
	//.abicalls
	.data
	.align	2
	.type	decoding_table, @object
	.size	decoding_table, 64
decoding_table:
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
	.type	decoding_table_size, @object
	.size	decoding_table_size, 4
decoding_table_size:
	.word	64
	.text
	.align	2
	.globl	DecodeChar
	.ent	DecodeChar
	.frame	$fp,24,ra		// vars= 8, regs= 2/0, args= 0, extra= 8
	.mask	0x50000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,24
	.cprestore 0
	sw	$fp,20(sp)
	sw	gp,16(sp)
	move	$fp,sp
	move	v0,a0
	sb	v0,8($fp)
	sb	zero,9($fp)
$L2:
	lbu	v0,9($fp)
	lw	v1,decoding_table_size
	slt	v0,v0,v1
	bne	v0,zero,$L5
	b	$L3
$L5:
	lbu	v0,9($fp)
	lbu	v1,decoding_table(v0)
	lb	v0,8($fp)
	bne	v1,v0,$L4
	lbu	v0,9($fp)
	sw	v0,12($fp)
	b	$L1
$L4:
	lbu	v0,9($fp)
	addu	v0,v0,1
	sb	v0,9($fp)
	b	$L2
$L3:
	lb	v1,8($fp)
	li	v0,61			// 0x3d
	bne	v1,v0,$L7
	sw	zero,12($fp)
	b	$L1
$L7:
	li	v0,100			// 0x64
	sw	v0,12($fp)
$L1:
	lw	v0,12($fp)
	move	sp,$fp
	lw	$fp,20(sp)
	addu	sp,sp,24
	j	ra
	.end	DecodeChar
	.size	DecodeChar, .-DecodeChar
	.align	2
	.globl	Decode
	.ent	Decode
Decode:
	.frame	$fp,64,ra		// vars= 24, regs= 4/0, args= 16, extra= 8
	.set	noreorder
	.cpload	t9
	.set	reorder
	subu	sp,sp,64
	.cprestore 16

	sw	ra,60(sp)
	sw	$fp,56(sp)
	sw	gp,52(sp)
	sw	s0,48(sp)

	//Trabajo con $fp
	move	$fp,sp

	//Se carga el archivo en a0, el buffer en a1 y la cantidad de bytes en a2
	sw	a0,64($fp)
	sw	a1,68($fp)
	sw	a2,5
	sw	zero,32($fp)
	
	addu	a1,$fp,32
	move	a0,zero
	//Primera lectura  
	jal	DecodeChar

	//destino de lectura
	addu	a1,$fp,32 
	//input fd
	lw	a0,64($fp) 
	//Leo 4 bytes
	li	a2,4 
	li v0,SYS_read
	//leo
	syscall
	//cargo lo que se leyó en v0 
	sw	v0,40($fp)

//Ciclo de lectura
$L9:
	lw	t1,40($fp)
	sltu	v0,v0,4
	blez	t1,$L12
	lw	t1,32($fp) //cargo state
	bnez	t1,$L12

	//destino
	addu a2,$fp,24
	lw	a0,64($fp) //fd in
	lw	a1,68($fp) //fd out
	lw	a3,40($fp) //read
	
	jal	DecodeChar
	
	//el resultado de decode se asigna a state
	sw	v0,32($fp)

	//se vuelve a repetir
	addu	v0,$fp,32 
	move	a1,v0
	move	a0,zero
	li	a2,5	
	jal	DecodeChar

	//destino de lectura
	addu a0,$fp,32 
	//input fd
	lw	a1,64($fp)
	//Leo 4 bytes
	li	a2,4 

	li v0,SYS_read
	syscall
	
	sw	v0,40($fp)
	//Sigue el ciclo
	b $L9
$L8:
	lw	v0,40($fp)
	move	sp,$fp
	lw	ra,60(sp)
	lw	$fp,56(sp)
	lw	s0,48(sp)
	addu	sp,sp,64
	j	ra
	.end	Decode
	.size	Decode, .-Decode
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
