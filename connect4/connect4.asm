DEFAULT REL

;section .bss

section .data
    msgStart db 'Connect 4 in Assembly', 10, 0
    lenStart equ $ - msgStart

    arr1 times 4 db '[ ]'
    lenArr1 equ $ - arr1

section .text
    global _start

_start:
    mov rax, 1        ; sys_write
    mov edi, 1        ; fd: stdout (clears upper 32 bits of rdi, saving 1 byte)
    mov rsi, msgStart ; buf: 64-bit memory address (MUST use rsi)
    mov rdx, lenStart ; count: length of string
    syscall

    mov rdi, msgStart
    call Print

    mov rdi, arr1
    call Print
    
    jmp exit


Print:
    ; RDI is the message we're sending
    ; message length is determined in this function
    
    push rdi ; put current value of rdi in stack (we give it to rsi later on)
    ;mov rsi, rdi ; could also just do this instead of push/pop... but whatever :)

    ; rcx is our counter variable, doesn't need anything exiting (thus why we clear it)
    xor rcx, rcx        ; Clear counter
    dec rcx             ; Set rcx to max value (0xFFFFFFFFFFFFFFFF)
    xor al, al          ; Search for null byte (0x00)
    repne scasb         ; Scan rdi until 0x00 is found (repne scasb always checks RDI)
    ; the loop modifies rcx (x86_64 works this way, and will always use rcx as a counter)


    not rcx             ; Invert bitmask to get string length + 1
    dec rcx             ; Subtract 1 to drop the null byte count (rcx now holds exact len)

    mov rax, 1 ; sys_write
    mov edi, 1 ; fd: stdout
    pop rsi ; pop gets last thing pushed to stack (rdi) - don't need; mov rsi, rdi ; string
    mov rdx, rcx ; message length
    
    
    syscall

    ret








; should always be last thing in code
exit:
    mov rax, 60             ; syscall number for sys_exit
    mov rdi, 0              ; exit code 0
    syscall



