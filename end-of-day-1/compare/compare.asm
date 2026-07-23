section	.text
   global _start	 ;must be declared for linker (gcc)
	
_start:
    mov edx, lenB
    mov ecx, valueB
    mov eax, 4 ; (sys_write)
    int 0x80

    mov r8, 15
    mov r9, 0xF

    cmp r8,r9 ; its an if statement!
    je isEqual
    jne isNotEqual



    mov	eax,1    ;system call number (sys_exit)
    int 0x80     ;call kernel

isEqual: 
    mov edx, len_equal
    mov ecx, text_equal
    mov rax, 4
    int 0x80
    
    jmp exit

isNotEqual:
    mov edx, len_notequal
    mov ecx, text_notequal
    mov eax, 4
    int 0x80

    jmp exit
exit:
    mov rax, 60             ; syscall number for sys_exit
    mov rdi, 0              ; exit code 0
    syscall

section .data
    valueA db 'hello'
    valueB db 'hello',0xa
    valueC db '10'
    valueD db 0xa
    valueE db 10

    lenB equ $ - valueB

    text_equal db 'is equal!',0xa
    len_equal equ $ - text_equal

    text_notequal db 'not equal!!',0xa
    len_notequal equ $ - text_notequal