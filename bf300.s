/*
 * Copyright (c) 2021 Brian Callahan <bcallah@openbsd.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

	.text
	.globl	main
main:
	pushq	$4
	popq	%rbx		# Store write(2) system call
	xorl	%ebp, %ebp	# Loop counter
	pushq	$1
	popq	%rdi		# Write prologue
	leal	.LSprologue, %esi
	pushq	$26
	jmp	.Lwrite
.Lparse:
	pushq	$3
	popq	%rax		# Load read(2) system call
	movl	%edi, %edx	# Read one character (%edi == 1)
	xorl	%edi, %edi	# Read from stdin
	leaq	(%rsp), %rsi	# Read into (%rsp)
	syscall			# read(0, (%rsp), 1);
	incl	%edi		# Set %edi to 1, for write
	cmpl	%edx, %eax	# EOF ? (%eax < 1)
	jl	.Leof
	movb	(%rsi), %al	# cmpb imm, %al is the smallest cmp
	leal	.LSleft, %esi	# Preload first string
	cmpb	$60, %al	# '<' ?
	je	.Lleft
	cmpb	$62, %al	# '>' ?
	je	.Lright
	cmpb	$45, %al	# '-' ?
	je	.Ldec
	cmpb	$43, %al	# '+' ?
	je	.Linc
	cmpb	$44, %al	# ',' ?
	je	.Lgetchar
	cmpb	$46, %al	# '.' ?
	je	.Lputchar
	cmpb	$91, %al	# '[' ?
	je	.Lopenloop
	cmpb	$93, %al	# ']' ?
	je	.Lcloseloop
	jmp	.Lparse		# Comment character, skip.
.Lwrite:
	popq	%rdx		# Number of characters to write
	movl	%ebx, %eax
	syscall			# write(1, string, sizeof(string));
	jmp	.Lparse
.Leof:
	cmpl	%edx, %ebp	# Loop counter < 1 ? (i.e., 0)
	jge	.Lexit
	leal	.LSepilogue, %esi
	pushq	$11
	popq	%rdx
	movl	%ebx, %eax
	syscall
	xorl	%edi, %edi	# Get ready to exit
.Lexit:
	pushq	$1
	popq	%rax		# _exit(%edi);
	syscall
.Lright:
	addl	%ebx, %esi	# aka, %esi + 4
.Lleft:
	pushq	%rbx		# aka, 4
	jmp	.Lwrite
.Ldec:
	subl	$5, %esi	# 13 - 5 = 8
.Linc:
	addl	$13, %esi
.Ldecinc:
	pushq	$5
	jmp	.Lwrite
.Lgetchar:
	addl	$18, %esi
	jmp	.Lgetcharputchar
.Lputchar:
	addl	$31, %esi
.Lgetcharputchar:
	pushq	$13
	jmp	.Lwrite
.Lopenloop:
	incl	%ebp		# Increment loop counter
	addl	$44, %esi
	pushq	$10
	jmp	.Lwrite
.Lcloseloop:
	decl	%ebp		# Decrement loop counter
	cmpl	$-1, %ebp	# Loop counter < 0 ?
	je	.Lexit		# %edi == 1 (from the write(2) call)
	addl	$89, %esi
	pushq	%rdi		# %rdi == 1 (from the write(2) call)
	jmp	.Lwrite

.LSleft:
	.ascii	"--p;"		# 4

.LSright:
	.ascii	"++p;"		# 4

.LSdec:
	.ascii	"--*p;"		# 5

.LSinc:
	.ascii	"++*p;"		# 5

.LSgetchar:
	.ascii	"*p=getchar();"	# 13

.LSputchar:
	.ascii	"putchar(*p); "	# 13

.LSopenloop:
	.ascii	"while(*p){"	# 10

.LSprologue:
	.ascii	"char a[65536],*p=a;main(){"	# 26

.LSepilogue:
	.ascii	"return 0;"	# 9

.LScloseloop:
	.ascii	"}"		# 1
	.ascii	"\n"		# 1
