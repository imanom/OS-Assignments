/*
 * kernel_entry.S - kernel initialization (Assignment 2, ECE 6504)
 * Copyright 2021 Ruslan Nikolaev <rnikola@vt.edu>
 */

.global _start

.code64
_start:
	cli							/* disable interrupts */

	leaq gdt(%rip), %rax		/* place the 'gdt' address */
	movq %rax, gdt_ptr+2(%rip)  /* into 'gdt_ptr' */
	lgdt gdt_ptr(%rip)

	movq $0x10, %rax			/* %ds = %ss = %es = 0x10 */
	movq %rax, %ds
	movq %rax, %ss
	movq %rax, %es

	xorq %rax, %rax				/* %fs = %gs = 0x00 */
	movq %rax, %fs
	movq %rax, %gs

	movq %rdi, %rsp					/* %rsp = the 1st arg */
	movq %rdi, kernel_stack(%rip)	/* also keep in kernel_stack */

	leaq syscall_entry(%rip), %rax	/* syscall_entry_ptr -> syscall_entry() */
	movq %rax, syscall_entry_ptr(%rip)

	leaq kernel_start(%rip), %rax
	pushq $0x08
	pushq %rax
	lretq						/* %cs = 0x08, jmp kernel_start */

/* Global Descriptor Table (GDT) */
.align 64
gdt:
	.quad 0x0000000000000000
	.quad 0x00af9b000000ffff	/* KERNEL code (64-bit) */
	.quad 0x00cf93000000ffff	/* KERNEL data (64-bit) */
	.quad 0x00cff3000000ffff	/* USER data (64-bit) */
	.quad 0x00af9b000000ffff	/* USER code (64-bit) */
	/* Please do *NOT* rearrange or move the above entries
	   due to the assumptions of SYSCALL/SYSRET!
	   But you can add other entries after them! */
gdt_end:

/*
 * GDT (80-bit) pointer
 * Note: we cannot simply place 'gdt' here because
 * we use a pure binary and position-independent code:
 * 'gdt' and other absolute addresses must be calculated using
 * (%rip)-relative addresses as in the code above
 */
.align 64
gdt_ptr:
	.word gdt_end-gdt-1			/* this is OK, addresses cancel out */
	.quad 0						/* must be initialized to 'gdt' (see above) */
