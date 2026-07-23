
section .data
    testDb db 'woah',0xa
    lenDb equ $ - testDb

    testDw dw '1234'
    testDd dd 'abcd'
    testDq dq 'woah'
    testDt dt 'woah'


section .text
    global _start

_start:
    ; Print the string
    ;mov edx, lenDb           ; Pass the exact length of the string (5 bytes)
    ;mov ecx, testDb         ; Pass the memory address of the string
    ;mov ebx, 1              ; Target stdout (Standard Output) - You missed this!
    ;mov eax, 4              ; sys_write
    ;int 0x80

    mov edx, 12
    mov ecx, testDb
    mov ebx, 1
    mov eax, 4
    int 0x80

    jmp exit
    
exit:

    mov eax, 1              ; 32-bit Linux syscall for sys_exit is 1
    mov ebx, 0              ; Return status code 0
    int 0x80
