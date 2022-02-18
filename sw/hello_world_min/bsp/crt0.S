.section .init, "ax"
.align 1
.global _reset_entry
.type _reset_entry, @function

_reset_entry:
	.cfi_startproc
	.cfi_undefined ra
	.option push
	.option norelax
	la		gp, __global_pointer$
	.option pop
	la		t1, trap_vector
	csrrw   x0, mtvec, t1
	la		t1, _timer_regh
	sw		x0, (t1)
	la		t1, _timer_regl
	sw		x0, (t1)
	la		t1, _timer_compregh
	sw		x0, (t1)
	la		t1, _timer_compregl
	sw		x0, (t1)
	la		sp, __stack
	mv		x1, x0
	mv		x4, x1
	mv		x5, x1
	mv		x6, x1
	mv		x7, x1
	mv		x8, x1
	mv		x9, x1
	mv		x10, x1
	mv		x11, x1
	mv		x12, x1
	mv		x13, x1
	mv		x14, x1
	mv		x15, x1
	mv		x16, x1
	mv		x17, x1
	mv		x18, x1
	mv		x19, x1
	mv		x20, x1
	mv		x21, x1
	mv		x22, x1
	mv		x23, x1
	mv		x24, x1
	mv		x25, x1
	mv		x26, x1
	mv		x27, x1
	mv		x28, x1
	mv		x29, x1
	mv		x30, x1
	mv		x31, x1

	add s0, sp, zero

	la x26, _bss_start
	la x27, _bss_end
	bge x26, x27, zero_loop_end

zero_loop:
	sw x0, 0(x26)
	addi x26, x26, 4
	ble x26, x27, zero_loop

zero_loop_end:
	la ra, main
	csrrw x0, mepc, ra		// on mret, mepc is the next pc
	mret					// jump to main, change of priv level to U and activation of interrupts
trap_vector:
    nop
    nop
    nop
    nop
	addi	sp,	sp,	-128
	sw	x1,	124(sp)
	sw	x2, 120(sp)
	sw	x3,	116(sp)
	sw	x4,	112(sp)
	sw	x5, 108(sp)
	sw	x6, 104(sp)
	sw	x7,	100(sp)
	sw	x8, 96(sp)
	sw	x9, 92(sp)
	sw  x10, 88(sp)
	sw	x11, 84(sp)
	sw	x12, 80(sp)
	sw	x13, 76(sp)
	sw	x14, 72(sp)
	sw	x15, 68(sp)
	sw	x16, 64(sp)
	sw	x17, 60(sp)
	sw	x18, 56(sp)
	sw	x19, 52(sp)
	sw	x20, 48(sp)
	sw	x21, 44(sp)
	sw	x22, 40(sp)
	sw	x23, 36(sp)
	sw	x24, 32(sp)
	sw	x25, 28(sp)
	sw	x26, 24(sp)
	sw	x27, 20(sp)
	sw	x28, 16(sp)
	sw	x29, 12(sp)
	sw	x30, 8(sp)
	sw	x31, 4(sp)
	// distinguish between exception and interrupt
	csrr x1, mcause
	bltz x1, handle_interrupt
	// exception
handle_exception:
	csrr t1, mepc
	mv	a0, x1
	lw	a1, 0(t1)
	jal x1, exception_handler
	beqz a0, handle_return
handle_emulated:
	csrr a0, mepc
	addi a0, a0, 4
	csrw mepc, a0
	j handle_return
handle_interrupt:
	mv	a0, x1
	jal ra, trap_handler

handle_return:
	lw	x1,	124(sp)
	lw	x2, 120(sp)
	lw	x3,	116(sp)
	lw	x4,	112(sp)
	lw	x5, 108(sp)
	lw	x6, 104(sp)
	lw	x7,	100(sp)
	lw	x8, 96(sp)
	lw	x9, 92(sp)
	lw  x10, 88(sp)
	lw	x11, 84(sp)
	lw	x12, 80(sp)
	lw	x13, 76(sp)
	lw	x14, 72(sp)
	lw	x15, 68(sp)
	lw	x16, 64(sp)
	lw	x17, 60(sp)
	lw	x18, 56(sp)
	lw	x19, 52(sp)
	lw	x20, 48(sp)
	lw	x21, 44(sp)
	lw	x22, 40(sp)
	lw	x23, 36(sp)
	lw	x24, 32(sp)
	lw	x25, 28(sp)
	lw	x26, 24(sp)
	lw	x27, 20(sp)
	lw	x28, 16(sp)
	lw	x29, 12(sp)
	lw	x30, 8(sp)
	lw	x31, 4(sp)
	addi	sp, sp, 128

	mret
	.cfi_endproc
	.end
