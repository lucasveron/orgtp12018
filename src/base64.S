#include <mips/regdef.h>
#include <sys/syscall.h>

	.data
	.align	2
sep:	.ascii 	"\n"
pad: 	.ascii	"="
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
	li	t1, 0		// count = 0
	
	//Limpio input para read
base64_encode_loop:
	sw	zero, 20($fp)	//input = 0
	
	//Leo archivo
	lw	a0, 40($fp)
	addi	a1, $fp, 20
	li	a2, 3
	li	v0, SYS_read
	syscall
	beqz	v0, base64_encode_return	//Si no lei nada finalizo //TODO: Chequear por error
	
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
	addi t1, t1, 1		// count++
	bne t1, 18, base64_encode_loop // Si count = 18 agrego un salto
	lw 	a0, 44($fp)	// file out
	la	a1, sep		// sep = '\n'
	li	a2, 1		// length = 4
	li	v0, SYS_write
	syscall   
	li	t1, 0
	j base64_encode_loop
		
base64_encode_return:	// return;
	// restauro callee-saved regs
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
	li	t1, 0		// count = 0
	la	t5, pad
	
	//Limpio input para read
base64_decode_loop:
	sw	zero, 20($fp)	//input = 0
	
	//Leo archivo
	lw	a0, 40($fp)
	addi	a1, $fp, 20
	li	a2, 4
	li	v0, SYS_read
	syscall
	beqz	v0, base64_decode_return	//Si no lei nada finalizo //TODO: Chequear por error
	//Controlo si hay padding
	li	t3, 0				//t3 = cant de padding a borrar
	lbu	t2, 43($fp)			//t2 aux control padding
	bne	t2, t5, ctl1
	addi 	t3, t3, 1
ctl1:	
	lbu	t2, 42($fp)			//t2 aux control padding
	bne	t2, t5, ctl2
	addi 	t3, t3, 1
ctl2:	
	//Controlo salto de linea
	addi t1, t1, 1		// count++
	bne t1, 18, not_sep 	// Si count = 18 elimino un caracter
	lw 	a0, 40($fp)	// file in
	addi	a1, $fp, 16	// grabo en out buffer, luego se pisa
	li	a2, 1		// length = 1
	li	v0, SYS_read
	syscall   
	li	t1, 0
	//Paso parametros y llamo a Decode
not_sep: 
	addi	a0, $fp, 20
	addi	a1, $fp, 16
	la 	t9, Decode
	jal 	ra, t9
				
	//Grabo en file
	lw 	a0, 44($fp)	// File descriptor out
	addi	a1, $fp, 16	// Apunto a buffer out
	li	t4, 3
	subu	a2, t4, t3	// a2 = 3 - cant de padding 
	li	v0, SYS_write
	syscall   
	j base64_decode_loop
		
base64_decode_return:	// return;
	// restauro callee-saved regs
	lw	gp, 24(sp)
	lw	$fp, 28(sp)
	lw	ra, 32(sp)
	// destruyo stack frame
	addu	sp, sp, 40
	// vuelvo a funcion llamante
	jr	ra
	.end	base64_decode
	.size	base64_decode, .-base64_decode

	
