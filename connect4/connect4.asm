DEFAULT REL

section .bss

section .data
    msgStart db 'Connect 4 in Assembly', 10, 0
    lenStart equ $ - msgStart

    arr1 times 4 db '[ ]'
    lenArr1 equ $ - arr1

    arrNum db 1,3,5,8,3,4,6,7

    
    ttt db 'TRUE',10,0
    fff db 'FALSE',10,0

    arrBoard times 3 db '[X][Y][Z]', 10 


    sum db 0

section .text
    global _start

_start:
    push rbp ; save the old base pointer (extern program called)
    mov rbp, rsp ; RBP takes the current snapshot of RSP
    sub rsp, 256 ; using rsp instead of rbp because that worked earlier

    mov rax, 1        ; sys_write
    mov edi, 1        ; fd: stdout (clears upper 32 bits of rdi, saving 1 byte)
    mov rsi, msgStart ; buf: 64-bit memory address (MUST use rsi)
    mov rdx, lenStart ; count: length of string
    syscall
;
;
; BULLSHIT TESTING BELOW!!!
;
;

    mov  eax, 3         ; Number of bytes to sum 
    mov  ebx, 0         ; Accumulator for sum
    mov  ecx, arrBoard  ; Pointer to current byte
    
    inc ecx ; START FROM 2nd CHARACTER
    mov [ecx], 'A'

    add ecx, 3
    mov [ecx], 'B'

    add ecx, 3
    mov [ecx], 'C'

    sub ecx, 6

    cmp byte [ecx], 'A'
    jne isFalse

    mov rdi, ttt
    jmp fin
isFalse:
    mov rdi, fff
    jmp fin
fin:
    call Print


    ; PRINT BOARD
    mov rdi, arrBoard
    call Print

    ; ADD LOOP


    mov  eax,4      ;number bytes to be summed 
    mov  ebx,0      ;EBX will store the sum
    mov  ecx, arrNum     ;ECX will point to the current element to be summed




    ;mov rdi, arrNum
    ;call Print
;
    ;mov rdi, msgStart
    ;call Print
    
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
    mov rsp, rbp ; RSP goes back to the original address (which rbp holds)
    pop rbp ; restore caller's RBP (which we pushed at _start)

    mov rax, 60             ; syscall number for sys_exit
    mov rdi, 0              ; exit code 0
    syscall



