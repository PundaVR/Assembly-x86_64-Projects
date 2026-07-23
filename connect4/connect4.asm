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

    arrBoard times 9 db '[0][1][2][3][4][5][6]', 10
    len_arrBoard equ $-arrBoard 


    sum db 0

section .text
    global _start

_start:
    push rbp ; save the old base pointer (extern program called)
    mov rbp, rsp ; RBP takes the current snapshot of RSP
    sub rsp, 64 ; using rsp instead of rbp because that worked earlier

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

    call InitBoard

    mov rdi, 4
    mov rsi, 5
    call GetTile

    mov rdi, rax
    ;call Print

    jmp exit

InitBoard:
    ; (xPos) Index of tile, will be 0,1,2,3,etc - RDI 
    ; (yPos) Row - RSI
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
    
    ; push rdi ; PUSH RDI (if we add more code in future)
    mov [rbp-64], rdi ; store arg1 in memory (index)
    mov [rbp-56], rsi;
    mov r8, arrBoard
    mov r9, 0 ; counter variable
    mov r10, 0 ; how many 0xA found
    xor r12, r12 ; holds amount of characters per line
    mov r13, 0 ; number of tiles per row
.StartLoop:
    ; CHECK IF REACHED END OF BOARD
    cmp r9, len_arrBoard ;compare counter index to arrBoardLength 
    je .FinishLoop ; IF counter > arrBoardLength
    
    ; LOOK FOR NEWLINE CHARACTER
    cmp byte [r8], 10
    je .FoundNewLine

.IncrementLoop:
    inc r9 ; increment counter
    inc r8 ; increment al

    jmp .StartLoop

.FoundNewLine:
    mov rdi, ttt
    call Print

    inc r10 ; inc amount of 0xA found
    cmp r10, 1
    jne .IncrementLoop ; if NOT first 0xA, continue

    ;ELSE:
    mov r12, r9 ; r12 now holds amount of chars per line 
    mov [rbp-48], r9 ; store in memory
    jmp .IncrementLoop

.FinishLoop:
    ret

GetTile:
    mov [rbp-64], rdi ; store arg1 in memory (index)
    mov [rbp-56], rsi;
    mov r8, arrBoard
    mov r9, 0 ; counter variable
    mov r10, 0 ; how many 0xA found
    xor r12, r12 ; holds amount of characters per line
    mov r13, 0 ; number of tiles per row

.ConvertArgToRawIndex:

; need to convert RDI into a raw index
; to get amount of tiles per row: ([r12]-1) / 3 

mov r13, 0 ; amount of tiles per row
mov rdi, [rbp-64] ; xPos
mov rsi, [rbp-56] ; yPos
mov r14, 1 ; raw index in array
; x has to be within range + 3
; +
; multiply yPos by [rbp-48]

    mul rdi, 3       ; xPos * 3
    mul rsi, [rbp-48] ; yPos * number of characters per row
    add r14, rdi     ; add xPos to index
    add r14, rsi     ; add yPos to index
    cmp rsi, 0       ; check if yPos is 0
    je .AssignRawIndex
    ;ELSE:
    add r14, [rbp-56] ; because anything not on first row is off by 1 char

.AssignRawIndex:
    mov  rcx, arrBoard  ; Pointer to current byte
    ;inc rcx ; START FROM 2nd CHARACTER


    add rcx, r14
    mov [rcx], 'X'

;;;;logic


mov [rbp-6], r13 ; store globally tiles per row




.GetTileEnd:

    mov rdi, arrBoard
    call Print
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



