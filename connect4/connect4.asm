DEFAULT REL

;section .bss

section .data
    msgStart db 'Connect 4 in Assembly', 10
    lenStart equ $ - msgStart

section .text
    global _start

_start:
    
    mov r12, 'poop'

    mov rax, 1        ; sys_write
    mov edi, 1        ; fd: stdout (clears upper 32 bits of rdi, saving 1 byte)
    mov rsi, msgStart ; buf: 64-bit memory address (MUST use rsi)
    mov rdx, lenStart ; count: length of string
    syscall








; should always be last thing in code
exit:
    mov rax, 60             ; syscall number for sys_exit
    mov rdi, 0              ; exit code 0
    syscall



