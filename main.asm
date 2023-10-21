

%include "lib.inc"
%include "dict.inc"
%include "words.inc"

section .data
error: db "current key not found", 0

section .bss 
key: resb 255

section .text

found_by_key:
  add rdi, 8        
  call string_length    
  add rdi, rax
  inc rdi
  mov rax, rdi
  mov rdi, rax
  call print_string
  ret

global _start
_start:
  mov rsi, 64
  mov rdi, key
  call read_word
  mov rdi, rax
  mov rsi, third
  call find_word
  cmp rax, 0
  je .not_found 
  call found_by_key

  .not_found:
  mov rdi, error
  call print_string

  .end:
  call exit
