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
	pushq	$3
	popq	%rbp		# Store read(2) system call
	pushq	$4
	popq	%rbx		# Store write(2) system call
	xorl	%r15d, %r15d	# Loop counter
	pushq	$1
	popq	%rdi		# Write prologue
	leal	.LSprologue, %esi
	pushq	$26
	jmp	.Lwrite
.Lparse:
	movl	%ebp, %eax	# Read next character in stream
	movl	%edi, %edx	# Read one character (%edi == 1)
	xorl	%edi, %edi	# Read from stdin
	leaq	(%rsp), %rsi	# Read into (%rsp)
	syscall			# read(0, (%rsp), 1);
	incl	%edi		# Set %edi to 1, for write
	cmpl	%edx, %eax	# EOF ? (%eax < 1)
	jl	.Leof
	cmpb	$60, (%rsi)	# '<' ?
	je	.Lleft
	cmpb	$62, (%rsi)	# '>' ?
	je	.Lright
	cmpb	$45, (%rsi)	# '-' ?
	je	.Ldec
	cmpb	$43, (%rsi)	# '+' ?
	je	.Linc
	cmpb	$44, (%rsi)	# ',' ?
	je	.Lgetchar
	cmpb	$46, (%rsi)	# '.' ?
	je	.Lputchar
	cmpb	$91, (%rsi)	# '[' ?
	je	.Lopenloop
	cmpb	$93, (%rsi)	# ']' ?
	je	.Lcloseloop
	jmp	.Lparse		# Comment character, skip.
.Lwrite:
	popq	%rdx		# Number of characters to write
	movl	%ebx, %eax
	syscall			# write(1, string, sizeof(string));
	jmp	.Lparse
.Leof:
	cmpl	%edx, %r15d	# Loop counter < 1 ? (i.e., 0)
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
.Lleft:
	leal	.LSleft, %esi
	jmp	.Lleftright
.Lright:
	leal	.LSright, %esi
.Lleftright:
	pushq	%rbx		# aka, 4
	jmp	.Lwrite
.Ldec:
	leal	.LSdec, %esi
	jmp	.Ldecinc
.Linc:
	leal	.LSinc, %esi
.Ldecinc:
	pushq	$5
	jmp	.Lwrite
.Lgetchar:
	leal	.LSgetchar, %esi
	jmp	.Lgetcharputchar
.Lputchar:
	leal	.LSputchar, %esi
.Lgetcharputchar:
	pushq	$13
	jmp	.Lwrite
.Lopenloop:
	incl	%r15d		# Increment loop counter
	leal	.LSopenloop, %esi
	pushq	$10
	jmp	.Lwrite
.Lcloseloop:
	decl	%r15d		# Decrement loop counter
	cmpl	$-1, %r15d	# Loop counter < 0 ?
	je	.Lexit		# %edi == 1 (from the write(2) call)
	leal	.LScloseloop, %esi
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
