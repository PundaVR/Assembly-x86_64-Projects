DEFAULT REL

section .bss

section .data
    msgStart db 'Connect 4 in Assembly', 10, 0
    lenStart equ $ - msgStart

    arr1 times 4 db '[ ]'
    lenArr1 equ $ - arr1

    arrNum db 1,3,5,8,3,4,6,7

    debugLine db '=====================================',10,0
    
    ttt db 'TRUE',10,0
    fff db 'FALSE',10,0

    arrBoard times 3 db '[X][Y][Z]', 10
    len_arrBoard equ $-arrBoard 


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
    
    mov rdi, 1
    mov rsi, 'A'
    call CompareTile

    cmp [rbp-1], 0
    je alFalse

    mov rdi, ttt
    jmp alFin
alFalse:
    mov rdi, fff
    jmp alFin
alFin:
    call Print

; 0, 1, 2
; 2, 5, 8
;

    mov rdi, debugLine
    call Print

    call GetTile

    jmp exit

GetTile:
    ; Index of tile, will be 0,1,2,3,etc - RDI 
    ; RETURN: actual position (i.e. RDI=3 -> RAX=8) - RAX


    ; We know there are 10 characters per line
    ; '[X][Y][Z]', 0xA
    ; The values are:
    ; > 2, 5, 8 (increments of 3)
    ; = X, Y, Z
    ;
    ; Goal is
    ; > 0, 1, 2
    ; = X, Y, Z
    ; 
    ; We have 3 rows, so if > 10 we can divide by 10 and use remainder
    ; We can search for amount of 0xA to determine number of rows 
    ; 
    ;
    ;
    ;

    ;;; FIND AMOUNT OF 0xA TO DETERMINE NUMBER OF ROWS
    
    ; push rdi ; PUSH RDI (r11) (if we add more code in future)
    mov r11, arrBoard
    mov r9, 0 ; counter variable
    ;mov al, byte [rdi] ; al contains byte we're looking at
    ;mov r8, len_arrBoard 
.StartLoop:
    

    cmp r9, len_arrBoard ;compare counter index to arrBoardLength 
    je .FinishLoop ; IF counter > arrBoardLength


    cmp r11, 10 ;WHYNOOWOROOOKKKK 
    je .debugA
    jmp .debugB ;jne



    
.IncrementLoop:
    inc r9 ; increment counter
    inc r11 ; increment al

    jmp .StartLoop

.debugA:
    mov rdi, ttt
    call Print
    jmp .IncrementLoop
.debugB:
    mov rdi, fff
    call Print
    jmp .IncrementLoop

.FinishLoop:

    ret


CompareTile:
    ; index - RDI (dil) holds the index of the tile (in future should be 1-9, not increments of 3)
    ; value - RSI (sil) holds what we are comparing for (i.e. 'A')
    
    ; [rbp-1] HOLDS BIT TO COMPARE

    ; EXAMPLE USAGE:
    ; mov rdi, 1
    ; mov rsi, 'A'
    ; call CompareTile
    ; cmp [rbp-1], 0
    ; je LABEL_TO_JUMP

    mov rcx, arrBoard ; holds arrBoard - ECX (cl)
    add rcx, rdi      ; add index to board pointer - RDI (dil) 
    
    cmp byte [rcx], sil      ; compare byte at board pointer to RSI (sil)
    jne .compareFalse

    mov [rbp-1], 1 ; RAX = TRUE
    jmp .compared
.compareFalse:
    mov [rbp-1], 0 ; RAX = FALSE
    jmp .compared
.compared:
    ret



PrintString:
    ; RDI - contains 
    ret

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



