section .data
    prompt_name db "Enter your name: ", 0
    len_name    equ $ - prompt_name

    prompt_age  db "Enter your age: ", 0
    len_age     equ $ - prompt_age

    msg_adult   db "Welcome, you are an adult!", 10, 0
    len_adult   equ $ - msg_adult

    msg_minor   db "Access denied. You are under 18.", 10, 0
    len_minor   equ $ - msg_minor

section .bss
    name_buffer resb 64    ; Reserve 64 bytes for name
    age_buffer  resb 8     ; Reserve 8 bytes for age input string

section .text
    global _start

_start:
    ; 1. Prompt for Name
    mov rax, 1              ; syscall number for sys_write
    mov rdi, 1              ; file descriptor 1 (stdout)
    mov rsi, prompt_name    ; pointer to our string
    mov rdx, len_name       ; length of string
    syscall

    ; 2. Read Name
    mov rax, 0              ; syscall number for sys_read
    mov rdi, 0              ; file descriptor 0 (stdin)
    mov rsi, name_buffer    ; where to store input
    mov rdx, 64             ; max bytes to read
    syscall

    ; 3. Prompt for Age
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_age
    mov rdx, len_age
    syscall

    ; 4. Read Age
    mov rax, 0
    mov rdi, 0
    mov rsi, age_buffer
    mov rdx, 8
    syscall

    ; 5. Convert Age String to Integer
    ; We parse ASCII digits stored in age_buffer into register R8
    xor r8, 0               ; Clear r8 (this will hold our final integer age)
    mov rsi, age_buffer     ; Point rsi to the beginning of the age string

.parse_loop:
    movzx rax, byte [rsi]   ; Get the current character
    cmp al, 10              ; Check if it's a newline character (\n)
    je .done_parsing
    cmp al, 0               ; Check for null terminator
    je .done_parsing
    cmp al, '0'             ; Ensure it's a valid digit
    jb .done_parsing
    cmp al, '9'
    ja .done_parsing

    sub al, '0'             ; Convert ASCII character to raw numeric digit ('5' becomes 5)
    imul r8, 10             ; Multiply previous total by 10 (e.g., 1 becomes 10 before adding next digit)
    add r8, rax             ; Add the new digit to the total
    inc rsi                 ; Move to the next character index
    jmp .parse_loop

.done_parsing:
    ; 6. Compare Age against 18
    cmp r8, 18              ; Compare parsed age with 18
    jge .is_adult           ; Jump to .is_adult if greater than or equal to 18

    ; 7. Handle Minor Case
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_minor
    mov rdx, len_minor
    syscall
    jmp .exit

.is_adult:
    ; 8. Handle Adult Case
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_adult
    mov rdx, len_adult
    syscall

.exit:
    ; 9. Clean Exit
    mov rax, 60             ; syscall number for sys_exit
    mov rdi, 0              ; exit code 0
    syscall