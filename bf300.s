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
	incl	%edi		# Write prologue
	leal	.LSprologue, %esi
	pushq	$26
	jmp	.Lwrite
.Lparse:
	movb	$3, %al		# Load read(2) system call
	movl	%edi, %edx	# Read one character (%edi == 1)
	xorl	%edi, %edi	# Read from stdin
	leaq	(%rsp), %rsi	# Read into (%rsp)
	syscall			# read(0, (%rsp), 1);
	incl	%edi		# Set %edi to 1, for write
	movl	%eax, %ecx	# Store return value in %ecx
	movb	(%rsi), %al	# cmpb imm, %al is the smallest cmp
	leal	.LS, %esi	# Preload first string
	cmpl	%edx, %ecx	# EOF ? (%ecx < 1)
	jl	.Leof
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
	movb	$4, %al
	syscall			# write(1, string, length);
	jmp	.Lparse
.Leof:
	cmpl	%edx, %ebx	# Loop counter < 1 ? (i.e., 0)
	jge	.Lexit
	addl	$54, %esi
	pushq	$11
	popq	%rdx
	movb	$4, %al
	syscall
	xorl	%edi, %edi	# Get ready to exit
.Lexit:
	movb	$1, %al		# _exit(%edi);
	syscall
.Lright:
	addl	$4, %esi
.Lleft:
	pushq	$4
	jmp	.Lwrite
.Ldec:
	subl	$5, %esi	# 13 - 5 = 8
.Linc:
	addl	$13, %esi
	pushq	$5
	jmp	.Lwrite
.Lgetchar:
	subl	$13, %esi	# 31 - 13 = 18
.Lputchar:
	addl	$31, %esi
	pushq	$13
	jmp	.Lwrite
.Lopenloop:
	incl	%ebx		# Increment loop counter
	addl	$44, %esi
	pushq	$10
	jmp	.Lwrite
.Lcloseloop:
	decl	%ebx		# Decrement loop counter
	cmpl	$-1, %ebx	# Loop counter < 0 ?
	je	.Lexit		# %rdi == 1 (from the write(2) call)
	addl	$63, %esi
	pushq	%rdi		# %rdi == 1 (from the write(2) call)
	jmp	.Lwrite

.LSprologue:
	.ascii	"char a[65536],*p=a;main(){"	# 26

.LS:
	.ascii	"--p;"		# 4
	.ascii	"++p;"		# 4
	.ascii	"--*p;"		# 5
	.ascii	"++*p;"		# 5
	.ascii	"*p=getchar();"	# 13
	.ascii	"putchar(*p); "	# 13
	.ascii	"while(*p){"	# 10
	.ascii	"return 0;"	# 9
	.ascii	"}"		# 1
	.ascii	"\n"		# 1
