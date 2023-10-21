

global exit
global string_length
global print_char
global print_newline
global print_int
global print_uint
global string_equals
global parse_int
global parse_uint
global string_copy
global read_char
global read_word

section .text

 exit:
         mov rax, 60
         syscall

; Принимает указатель на нуль-терминированную строку, возвращает её длину
  string_length:
        xor rax, rax
        mov rax, -1
       .count:
        inc rax
        cmp byte[rdi + rax], 0
        jne .count
        ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
 print_string:
        push rdi
        call string_length
        pop rsi
        mov rdx, rax
        mov rax, 1
        mov rdi, 1
        syscall
        ret


; Принимает код символа и выводит его в stdout
print_char:
        push rdi
        mov rdi, 1
        mov rax, 1
        mov rdx, 1
        mov rsi, rsp
        syscall
        add rsp, 8 
        ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
        ;mov rax, 1
        ;mov rdi, 1
        ;mov rsi, 0xA

        mov rdi, 0xA 
        call print_char

        ret

; Выводит беззнаковое 8-байтовое число в десятичном формате
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
        mov rcx, 8
        mov rax, rdi
        mov rsi, 0xA
        mov r8, 8

        push 0x0
        .loop:
        xor rdx, rdx
        div rsi
        add rdx, '0'
        dec rsp
        mov byte[rsp], dl
        inc rcx
        test rax, rax
        jne .loop

        mov rdi, rsp
        add rcx, rdx
        sub rsp, rdx
        push rcx
        call print_string
        pop rcx
        add rsp, rcx
        ret

; Выводит знаковое 8-байтовое число в десятичном формате
print_int:
        test rdi, rdi
        jns print_uint
        push rdi
        mov rdi, '-'
        call print_char
        pop rdi
        neg rdi
        jmp print_uint
        ret


; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
        push r12 ;
        .check_length:
        push rdi ; заносим в стек rdi
        push rsi ; заносим в стек rsi
        call string_length ; вызов функции string_length

        mov r12, rax 
	pop rdi
        push rdi
        call string_length
        pop rsi
        pop rdi
        cmp rax, r12
        jne .non_equals
    xor rax, rax
    .loop:
        test r12, r12
        je .equals
        mov r9b, byte[rsi + rax]
        cmp byte[rdi + rax], r9b
        jne .non_equals
        inc rax
        dec r12
        jmp .loop
    .non_equals:
        pop r12
        xor rax, rax
        ret
    .equals:
        pop r12
        mov rax, 1
        ret



; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
        xor rdi, rdi
        xor rax, rax
        push 0
        mov rdx, 1
        mov rsi, rsp
        syscall

        cmp rax, -1
        jne .success

        mov rax, 0
        ret

        .success:
        pop rax
        ret

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращiает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
        push r12
        push r13
        push r14
        mov r12, rsi
        mov r14, rdi
   	xor r13,r13
     .read_word:
        call read_char
	cmp rax, ' '
        je .read_word
        cmp rax, 9
        je .read_word
        cmp rax, 10
        je .read_word
    .read:
        cmp r12, r13   
        jb .mistake
        cmp rax, 0x0
        je .close
        cmp rax, 0xA
        je .close
        cmp rax, 0x9
        je .close
        cmp rax, ' '
        je .mistake
        mov byte[r13+r14], al   
        inc r13
        call read_char
        jmp .read
    .close:
	mov rdx, r13
        mov [r14+rdx], byte 0   
        mov rax, r14
	pop r14
	pop r13
	pop r12
        ret
    .mistake:
       	mov rdx, r13
	pop r14
        pop r13
        pop r12
        xor rax, rax
        ret

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
        xor rax, rax
        xor r9, r9
        mov r10, 0xA
        xor rcx, rcx

        .loop:
                mov r9b, byte[rdi+rcx]
                xor r9b, '0'
                cmp r9b, 9
                ja .end
                mul r10
                add al, r9b
                inc rcx
        jmp .loop
        .end:
                mov rdx, rcx
                ret




; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был)
; rdx = 0 если число прочитать не удалось
parse_int:
        mov r9b, byte[rdi]
        cmp r9b, '+'
        mov r9b, byte[rdi]
        cmp r9b, '-'
        jne parse_uint
        inc rdi
        call parse_uint
        test rdx, rdx
        je .end
        neg rax
        inc rdx
        .end:
                ret


; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
        push rsi
        push rdx
        push rdi
        call string_length
        pop rdi
        pop rdx
        pop rsi
        inc rax
        cmp rdx, rax
        jb .mistake
        mov r10, rax
        xor rcx, rcx
  .loop:
        mov r9b, byte[rdi + rcx]
        mov byte[rsi + rcx], r9b
        inc rcx
        dec r10
        test r10, r10
        jne .loop
        ret
  .mistake:
        xor rax, rax
         ret

