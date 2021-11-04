	.file	"myblas.c"
	.text
	.globl	dewvm
	.type	dewvm, @function
dewvm:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -20(%rbp)	# N - 32 BITS
	movq	%rsi, -32(%rbp) # X - POINTERS ARE 64 BITS
	movq	%rdx, -40(%rbp) # Y
	movq	%rcx, -48(%rbp) # RESULT
	movl	$0, -4(%rbp)	#COUNTER I = 0
	jmp	.L2
.L3:
	# RESULT = 8*I
	# POINTER MATH FOR RESULT
	movl	-4(%rbp), %eax
	cltq 	# 64 BIT PROMOTION OF A 32 BIT NUMBER
	leaq	0(,%rax,8), %rdx # RDX <- 8 * I
	movq	-48(%rbp), %rax	# RAX <- RESULT
	addq	%rdx, %rax	# RESULT += 8*I
	# COMPILER: *RESULT + 8*I ... RECALC THE CURRENT ADDR EACH
	# TIME
	# MIPS: HAD A POINTER, INCREMENTED AS NEEDED
	
	# X = 8*I
	movl	-4(%rbp), %edx # GET I
	movslq	%edx, %rdx # PROMOTE TO 64 BITS
	leaq	0(,%rdx,8), %rcx
	movq	-32(%rbp), %rdx
	addq	%rcx, %rdx # x += 8*I
	movupd	(%rdx), %xmm1 # LW SIMD, FP
	
	# Y = 8*I
	movl	-4(%rbp), %edx
	movslq	%edx, %rdx
	leaq	0(,%rdx,8), %rcx
	movq	-40(%rbp), %rdx
	addq	%rcx, %rdx
	movupd	(%rdx), %xmm0
	
	mulpd	%xmm1, %xmm0
	
	movupd	%xmm0, (%rax) #SW
	
	addl	$2, -4(%rbp) #I++
.L2:
	movl	-4(%rbp), %eax 	# I
	cmpl	-20(%rbp), %eax	# N
	jl	.L3
	
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	dewvm, .-dewvm
	.ident	"GCC: (Debian 6.3.0-18+deb9u1) 6.3.0 20170516"
	.section	.note.GNU-stack,"",@progbits
	
	#UNMODIFIED TIMING
	#user 0.350s
	#user 0.325s
	#user 0.352s
	
	#MODIFIED TIMING
	#user 0.188s
	#user 0.186s
	#user 0.191s