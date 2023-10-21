%include "lib.inc"

global find_word

section .text

;принимает два аргумента 1) указатель на нуль-терминированную строку 2) имя метки, указатель начала словаря
find_word:
	push r15
	mov r15, [rsi]
	.loop:
	mov rsi, [r15+8]
	call string_equals
	cmp rax, 0
	jnz .key_error
	mov rax, r15
	jmp .end	

	.key_error:
	mov rax, 0
	

	.end:
		pop r15
		ret
	
