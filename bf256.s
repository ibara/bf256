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
	movb	$21, %dl
	jmp	.Lwrite
.Lparse:
	movb	$3, %al		# Load read(2) system call
	xchg	%edi, %edx	# Read one character
	xorl	%edi, %edi	# Read from stdin
	leaq	(%rsp), %rsi	# Read into top of stack
	syscall			# read(0, (%rsp), 1);
	incl	%edi		# Set %edi to 1, for write
	xchg	%ebp, %eax	# Store return value in %ebp
	movb	(%rsi), %al	# cmpb imm, %al is the smallest cmp
	leal	.LS, %esi	# Preload string
	cmpl	%edx, %ebp	# EOF ? (%ebp < 1)
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
	jne	.Lparse		# Comment character, skip
	decl	%ebx		# Decrement loop counter
	js	.Lexit		# %ebx < 0 ? (%rdi == 1 from the write(2) call)
	addl	$47, %esi
	jmp	.Lwrite
.Linc:
	addl	$6, %esi
.Ldec:
	movb	$6, %dl
.Lwrite:
	movb	$4, %al
	syscall			# write(1, string, length);
	jmp	.Lparse
.Leof:
	cmpl	%edx, %ebx	# Loop counter < 1 ? (i.e., 0)
	jge	.Lexit
	addl	$47, %esi
	movb	$4, %al
	syscall
	xorl	%edi, %edi	# Get ready to exit
.Lexit:
	xchg	%edx, %eax	# _exit(%edi);
	syscall
.Lleft:
	subl	$6, %esi	# 7 - 6 = 1
.Lright:
	addl	$7, %esi
	movb	$5, %dl
	jmp	.Lwrite
.Lgetchar:
	subl	$12, %esi	# 24 - 12 = 12
.Lputchar:
	addl	$24, %esi
	movb	$13, %dl
	jmp	.Lwrite
.Lopenloop:
	incl	%ebx		# Increment loop counter
	addl	$37, %esi
	movb	$10, %dl
	jmp	.Lwrite

.LSprologue:
	.ascii	"a[65536],*p=a;main(){"	# 21

.LS:
	.ascii	"*p-=1;"	# 6
	.ascii	"*p+=1;"	# 6
	.ascii	"*p=getchar();"	# 13
	.ascii	"putchar(*p);"	# 12
	.ascii	"while(*p){"	# 10
	.ascii	"}"		# 1
