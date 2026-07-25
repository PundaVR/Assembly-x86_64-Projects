DEFAULT REL
;;; PROJECT DATE: 23/07/2026
; First proper project in asm
; what
section .bss
    printText resb 32
    userInput resb 32

section .data
    msgStart db 'Connect 4 in Assembly', 10, 0
    lenStart equ $ - msgStart
    
    player1 db '[O] Player 1',10 ; read 12 bytes to ignore newline 
    player2 db '[X] Player 2',10 ; read 13 bytes to include newline

    msgRequestInput db 'Enter position to drop token (i.e. 3): '
    len_RequestInput equ $ - msgRequestInput

    newLineChar db 0xA ; newline char

    msgBoardPos db ' 0  1  2  3  4  5  6  7  8  9', 10
    len_BoardPos equ $-msgBoardPos

    arrBoard times 9 db '[ ][ ][ ][ ][ ][ ][ ][ ][ ]',10
    len_arrBoard equ $-arrBoard 

section .text
    global _start

_start:
    push rbp ; save the old base pointer (extern program called)
    mov rbp, rsp ; RBP takes the current snapshot of RSP
    sub rsp, 128 ; using rsp instead of rbp because that worked earlier

    mov rax, 1        ; sys_write
    mov edi, 1        ; fd: stdout (clears upper 32 bits of rdi, saving 1 byte)
    mov rsi, msgStart ; buf: 64-bit memory address (MUST use rsi)
    mov rdx, lenStart ; count: length of string
    syscall

SetupVariables:
    mov [rbp-1], 0 ; game active = true (1) 
    call InitBoard ; MUST CALL THIS ON PROGRAM START
    


Test:
    ;;; SET TILE ON BOARD
    mov rdi, 7   ; x position
    mov rsi, 4   ; y position
    mov rdx, 'X' ; symbol to show
    call SetTile
    
    ;;; PRINT THE BOARD
    call PrintBoard

    mov rdi, msgRequestInput
    call GetUserInput


    
    mov rdi, [userInput]
    call Print
    
    ;jmp exit


GameLoop:
    ; loop that runs forever
    mov rdi, 'hi'
    call Print
    mov rdi, 'poop'
    call PrintLn

    cmp [rbp-1], 0; check if game over
    jne GameLoop
    jmp exit 


GetUserInput:
    ; RDI will be message to send (16 bytes)
    ; RETURN: RAX userInput (also stored in 'userInput')

    mov rsi, rdi
    mov rdx, len_RequestInput
    mov rax, 1
    mov rdi, 1
    syscall 

    mov rsi, userInput
    mov rdx, 32
    mov rax, 0
    mov rdi, 0
    syscall

    mov rax, userInput
    ret


InitBoard:
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
   

    ;;; FIND AMOUNT OF 0xA TO DETERMINE NUMBER OF ROWS
    
    ; push rdi ; PUSH RDI (if we add more code in future)
   
    mov r8, arrBoard
    mov r9, 0 ; counter variable
    mov r10, 0 ; how many 0xA found
    
.StartLoop:
    ; CHECK IF REACHED END OF BOARD
    cmp r9, len_arrBoard ;compare counter index to arrBoardLength 
    je .FinishLoop ; IF counter == arrBoardLength
    
    ; LOOK FOR NEWLINE CHARACTER
    cmp byte [r8], 10
    je .FoundNewLine

.IncrementLoop:
    inc r9 ; increment counter
    inc r8 ; increment al

    jmp .StartLoop

.FoundNewLine:
    mov rdi, 'FOUNLINE'
    call PrintLn

    inc r10 ; inc amount of 0xA found
    cmp r10, 1
    jne .IncrementLoop ; if NOT first 0xA, continue

    ;ELSE:
    mov [rbp-48], r9 ; store in memory amount of chars per line
    jmp .IncrementLoop

.FinishLoop:
    mov [rbp-40], r10 ; store how many lines there are
    ret





SetTile: 
    ; xPos - RDI
    ; yPos - RSI
    ; char - RDX
    ; RETURN: pointer to correct tile
    ;
    ; USAGE EXAMPLE
    ; mov rdi, 4
    ; mov rsi, 2
    ; mov rdx, 'O'
    ; call SetTile

    mov [rbp-32], rdx ; store RDX in stack
    call GetTile ; get the tile (this overwrites rdi/rsi/rdx/etc)
    mov r15b, [rbp-32] ; get the 8 bytes from rbp
    mov [rax], r15b ; write the character to the tile position
    ret

GetTile:
    ; (xPos) Index of tile, will be 0,1,2,3,etc - RDI 
    ; (yPos) Row - RSI
    ; RETURN: pointer to correct tile (char in string)
    mov [rbp-64], rdi ; store arg1 in memory (index)
    mov [rbp-56], rsi;

.ConvertArgToRawIndex:

    ; need to convert RDI into a raw index
    ; to get amount of tiles per row: ([r12]-1) / 3 
    
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
    ;mov [rcx], 'X'
    mov rax, rcx ; RETURN POINTER TO THE CORRECT TILE
    ret


CompareTile:
    ; index - RDI (dil) holds the index of the tile (in future should be 1-9, not increments of 3)
    ; value - RSI (sil) holds what we are comparing for (i.e. 'A')
    
    ; [rbp-7] HOLDS BIT TO COMPARE

    ; EXAMPLE USAGE:
    ; mov rdi, 1
    ; mov rsi, 'A'
    ; call CompareTile
    ; cmp [rbp-7], 0
    ; je LABEL_TO_JUMP

    mov rcx, arrBoard ; holds arrBoard - ECX (cl)
    add rcx, rdi      ; add index to board pointer - RDI (dil) 
    
    cmp byte [rcx], sil      ; compare byte at board pointer to RSI (sil)
    jne .compareFalse

    mov [rbp-7], 1 ; RAX = TRUE
    jmp .compared
.compareFalse:
    mov [rbp-7], 0 ; RAX = FALSE
    jmp .compared
.compared:
    ret


PrintBoard:
    mov rsi, arrBoard
    mov rdx, len_arrBoard
    mov rax, 1       
    mov rdi, 1       
    syscall
    ret

Print:
    ; RDI - contains text to print 


    mov [rbp-128], rdi
    
    lea rsi, [rbp-128]
    mov rdx, 32
    mov rax, 1       
    mov rdi, 1     
    syscall  

    ret

PrintLn: 
    call Print

    mov rsi, newLineChar
    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall
    ret


; should always be last thing in code
exit:
    mov rsp, rbp ; RSP goes back to the original address (which rbp holds)
    pop rbp ; restore caller's RBP (which we pushed at _start)

    mov rax, 60             ; syscall number for sys_exit
    mov rdi, 0              ; exit code 0
    syscall



