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

    arrBoard times 9 db '[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]',10
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
    mov [rbp-1], 1 ; game active = true (1)  (only set zero if testing)
    call InitBoard ; MUST CALL THIS ON PROGRAM START
    mov [rbp-8], 2 ; 2 for only x ; 3 for x and y input
    mov [rbp-6], 'X' ;player1
    mov [rbp-5], 'O' ;player2
    mov [rbp-4], 'X' ; make player2 instead of 1, as loop will flip this to 1 
    ;;; SET TILE ON BOARD
    mov rdi, 7   ; x position
    mov rsi, 4   ; y position
    mov rdx, 'X' ; symbol to show
    call SetTile

GameLoop:
    ; loop that runs forever
    ;;; PRINT THE BOARD (should be at the start of every gameloop)
    call PrintBoard

    ; Determine what player turn it is
    call NextPlayerTurn

    ;; GET USER INPUT
.GetInput:
    mov rdi, msgRequestInput
    call GetUserInput
    call ParseUserInput ; VALIDATE INPUT
    cmp eax, 0 ; validate user input
    je .GetInput    

    
    movzx rdi, byte [rbp-3]   ; x position
    movzx rsi, byte [rbp-2]   ; y position
    mov dl, [rbp-4]; 'X' ; symbol to show
    call SetTile

    mov rdx, 0 ; check from left
    call DidPlacementWinGame

    cmp [rbp-1], 0; check if game over
    jne GameLoop
    jmp exit
    ret


DidPlacementWinGame:
    ; RDI x pos
    ; RSI y pos
    ; RDX 0=left 1=middle 2=right (will work from 0 to 2)
    ;     so passing 0 will do all three, passing 2 will only do right
    
    ; rbp-64 holds GetTile: x
    ; rbp-4 holds last player turn
    ; rbp-3 holds last X user input

    ; check surrounding cells
    ; if one matching, check following 2 cells
    ; if all match, WIN!
    mov [rbp-7], byte dl ; store RDX
    mov [rbp-9], byte 0
    movzx r14, byte [rbp-64] ; original user xPos
    movzx r15, byte [rbp-56] ; original user yPos

    mov r12, r14 ; r12 holds X (we iterate through)
    dec r12 ; move left a tile
    
    mov r13, r15 ; r13 holds Y (we iterate through) 

.StartCheckLoop:
    
    mov [rbp-11], byte 0
    mov [rbp-12], byte 0
    mov [rbp-13], byte 0
    mov [rbp-14], byte 0

    cmp byte [rbp-7], 3 ; 3 = is dont do any checks, 4 = idk
    je .EndWinningChecks

    ;;; X pos is done inside the subroutines
    mov r12, r14
    dec r12
    movzx rdi, byte [rbp-7]
    add r12, rdi

    ;;; SET Y POS FOR NEXT CHECK
    mov r13, r15     ; reset r13 to be original yPos
    dec r13          ; -1 (because we plus 0 1 or 2 later)
    movzx rdi, byte [rbp-9]
    add r13, rdi ; plus 0 1 or 2 (0 being above original, 1 being inline, 2 being below)

    cmp byte [rbp-7], 1
    jl .CheckLeft
    je .CheckMiddle 
    jg .CheckRight

.IncrementCheckSide:
    inc byte [rbp-7] ; check side
    mov [rbp-9], byte 0 ; reset tile counter to 0
    jmp .StartCheckLoop

.CheckLeft:
    cmp byte [rbp-9], 2 ;Check if tile counter > 2 (0,1,2)
    jg .IncrementCheckSide
    inc [rbp-9]

    mov rdi, 'CHECK L'
    call PrintLn 
    
    mov rdi, r12 ; xPos in rdi
    mov rsi, r13 ; yPos in rsi
    mov rdx, 'L'
    ;call SetTile ; get tile at pos

    jmp .LookForMatchingTile

.CheckMiddle:
    cmp byte [rbp-9], 1 ;Check if tile counter > 2 (0,1,2)
    jg .IncrementCheckSide
    inc [rbp-9]

    cmp byte [rbp-9], 1
    jle .SkipMiddle 
    inc r13

.SkipMiddle:

    mov rdi, 'CHECK M'
    call PrintLn 
    
    mov rdi, r12 ; xPos in rdi
    mov rsi, r13 ; yPos in rsi
    mov rdx, 'M'
    ;call SetTile ; get tile at pos

    jmp .LookForMatchingTile

.CheckRight:
    cmp byte [rbp-9], 2 ;Check if tile counter > 2 (0,1,2)
    jg .EndWinningChecks    
    inc [rbp-9]

    mov rdi, 'CHECK R'
    call PrintLn 
    
    mov rdi, r12 ; xPos in rdi
    mov rsi, r13 ; yPos in rsi
    mov rdx, 'R'
    ;call SetTile ; get tile at pos

    jmp .LookForMatchingTile

.LookForMatchingTile:
    mov rdi, r12
    mov rsi, r13
    call GetTile
    mov dil, [rbp-4]
    cmp byte [rax], dil
    je .FoundMatchingTile


    ;mov rdi, r14
    ;mov rsi, r15
    ;mov rdx, 'W'
    ;call SetTile
    ;jmp .CheckLeft
    jmp .StartCheckLoop

.FoundMatchingTile:

    mov rdi, r12
    mov rsi, r13
    mov rdx, 'W'
    ;call SetTile

    ;;;;;;;;;;;;;;; i dunno bro!
    push r14
    sub r14, r12
    ; prints '41' for example (r12 r14)
    mov rdi, r12
    add rdi, 48
    call Print
    mov rdi, r14
    add rdi, 48
    call PrintLn
    pop r14
    ;;;;;;;;;;;;;

    ; GET DIRECTION OF TILE FROM ORIGIN
    ; CHECK NEXT 2

    movzx rdi, byte [rbp-7] ; CHECK SIDE (x)
    movzx rsi, byte [rbp-9] ; TILE COUNT (y)
    
    ;cmp r12, 

    push r14
    push r15
    
    mov rdi, 'WOAH AAA'
    call PrintLn
    
    lea rdi, [rdi+r12+48] ; its math bro
    ;mov rdi, r12
    ;add rdi, 48
    call Print
    mov rdi, r14
    add rdi, 48
    call PrintLn

    mov rdi, r13
    add rdi, 48
    call Print
    mov rdi, r15
    add rdi, 48
    call PrintLn

    ; r14/15 holds original position
    ; r12/13 hold nearby tile we're now checking
    sub r12, r14;sub r14, r12 ; if -1 its left, 1 is right 
    sub r13, r15;sub r15, r13 ; if -1 its above, 1 is below

    mov rdi, 'NEG/POS '
    call Print
    lea rdi, [r12+48]
    call Print
    lea rdi, [r13+48]
    call PrintLn

    ; add r12, r14
    ; add r13, r15

.CheckFirst:   
    lea rdi, [r12+r14]
    lea rsi, [r13+r15]
    call GetTile

    mov dil, [rbp-4] ; COMPARE IF TILE IS SAME
    cmp byte [rax], dil
    jne .StartCheckLoop

    ; go increment the connection count, and return to next register    
    call IncrementConnections

.CheckSecond:
    lea rdi, [r12*2+r14]
    lea rsi, [r13*2+r15]
    call GetTile

.CheckThird:
    lea rdi, [r12+r12*2]
    add rdi, r14
    lea rsi, [r13+r13*2]
    add rsi, r15
    call GetTile

    
    pop r15
    pop r14

    ; IF NOT CONNECT4:    
    jmp .StartCheckLoop



.EndWinningChecks:
    mov rdi, 'CHECKWIN'
    call PrintLn

    mov r9, 1
.EndWinningLoop:
    cmp r9, 4
    jg .FinishWinningChecks
    
    movzx r8, byte [rbp-15+r9]

    mov rdi, r8
    add rdi, 48
    call PrintLn

    

    cmp r8, 4
    jge .WonTheGame



    inc r9
    jmp .EndWinningLoop

.WonTheGame:
    mov rdi, "FUCK YES"
    call PrintLn
.FinishWinningChecks:
    ret

IncrementConnections:
    push r12
    push r13

    mov rdi, r12
    mov rsi, r13

    add rdi, rsi
    
    cmp rdi, 0
    jl .IsLessLol
.IsPositive:
    ;othershit
    jmp .GotVector

.IsLessLol:
    imul rdi, rdi, -1
    ;add rdi, 48
    ;call PrintLn


.GotVector:
    mov [rbp-10], dl ; store vector for this turn

    cmp dl, 1
    jg .VectorIsTwo
    jl .VectorIsZero

    ;; do baloney
    cmp r12, 0 ; check if x is zero
    je .VectorIsAlongX


.VectorIsAlongY:
    inc [rbp-13]
    jmp .FinishIncrementing 

.VectorIsAlongX:
    inc [rbp-14]
    jmp .FinishIncrementing

.VectorIsTwo: ; POSITIVE DIAG
    inc [rbp-11]
    jmp .FinishIncrementing

.VectorIsZero: ; NEGATIVE DIAG
    inc [rbp-12]
    jmp .FinishIncrementing

.FinishIncrementing:
    

    pop r13
    pop r12
    ret



ApplyGravityToTile:
    ; modify y until tile found (or reached end)
    ; rbp-40 holds number of rows in board
    ; iterate through every row, at x pos
    ;   until we get to END or a non-empty tile
    ; return new yPos (rax) ALSO update [rbp-3] to hold new yPos

    mov r12, 0 ; counter (yPos)
    movzx r13, byte [rbp-3]

.StartGravityLoop:
    cmp r12, [rbp-40] ; check if Y == amount of rows
    jge .EndGravityLoop

    movzx rdi, byte [rbp-3] ; xPos
    mov rsi, r12
    call GetTile

    cmp byte [rax], ' ' ;32 ;space
    jne .EndGravityLoop
    
    inc r12
    jmp .StartGravityLoop

.EndGravityLoop:
    
    dec r12
    mov [rbp-2], r12b

    mov rax, r12
    ret

NextPlayerTurn:
    ; check current player
    ; flip ig?
    mov r13b, byte [rbp-6] ; r13b holds player 1
    cmp byte [rbp-4], r13b
    jne .CurrentPlayer2

    mov r15b, byte [rbp-5] ; r15 holds player 2

    mov [rbp-4], r15b 
    jmp .SetPlayerTurn

.CurrentPlayer2:
    mov r14b, [rbp-6]
    mov [rbp-4], r14b
    jmp .SetPlayerTurn

.SetPlayerTurn:
    movzx rax, byte [rbp-4]
    ret

GetUserInput:
    ; RDI will input message ENUM {
    ; 0 = "Invalid Input"
    ; 1 = "1 Digit Position Input"
    ; 2 = "2 Digit Position Input"
    ; }
    ; 
    ; RETURN: RAX userInput (also stored in 'userInput')

    mov rsi, rdi
    mov rdx, len_RequestInput
    mov rax, 1
    mov rdi, 1
    syscall 
    
    movzx r15, byte [rbp-8]

    mov rsi, userInput
    lea rdx, byte [rbp-8]
    mov rax, 0
    mov rdi, 0
    syscall

    mov rax, [userInput]
    ret


ParseUserInput:
; User input can be any of the following:
; - 'a1' (x0 y1)
; - '3A' (x3 y0)
; - '27' (x2 y7)
; - 'DE' (x3 y4)
; - 'A' (just X) - in the case of only 1 byte, its just X pos

; Need to validate X and Y input, each is 1 byte
; - we always only check for 2 bytes, so should be an easy loop
; - convert ascii to raw number (-48)
; - do cmp checks
; - give raw value to rdi,rsi

    ; STORE IN MEMORY EACH BYTE (from RAX)
    mov byte [rbp-3], al ; xPos

    cmp byte [rbp-8], 2
    je .OnlyParseFirstInput

    ; ELSE: also parse y input
    mov byte [rbp-2], ah ; yPos
    jmp .ConvertAsciiToNumber
.OnlyParseFirstInput:
    mov byte [rbp-2], '0' ; set yPos same as xPos
    jmp .ConvertAsciiToNumber
    ;inc rax
    ;mov r9b, byte [rax]
    
    
.ConvertAsciiToNumber:
;     mov rdi, ''
;     call PrintLn
;     ; PRINT OUT POSITIONS
;     mov rdi, 'X POS: '
;     call Print
;     movzx rdi, byte [rbp-3]
;     call PrintLn
;  
;     mov rdi, 'Y POS: '
;     call Print
;     movzx rdi, byte [rbp-2]
;     call PrintLn

    ; CONVERT ASCII TO NUMBER
    mov r10, -4 ; we always know its gonna be 2 characters!
    mov r14, -2 ; loop end condition
.AsciiStartLoop:
    inc r10 ; -3 then -2 (then loop finish) - r10 is rbp pointer
    mov r8b, [rbp+r10] ; r8b holds ASCII value
    
    mov r9b, r8b ; r9b will hold raw value
    sub r9b, 48  ; sub -48 to turn ascii to raw value

    ; r10 = 3 (rbp-3)
    ; r10 = 2 (rbp-2)
    ; r10 = 1 (jump out of loop)
    cmp r10, r14;-2 ; r10
    jg .AsciiDone

    cmp r9b, 9
    jle .AsciiLessThanOrEqualTo9
    jg .AsciiGreaterThan9

    
.AsciiGreaterThan9:
    cmp r9b, 17 ; 65(A) - 48 = 17
    jl .AsciiLessThan0
    cmp r9b, 42 ; 90(Z) - 48 = 42
    jg .AsciiProbablyLowercase


    ; SUBTRACT TO GET RAW
    sub r9b, 17

    mov rdi, 'UPPER'
    call PrintLn
    
    jmp .AsciiLooped

.AsciiProbablyLowercase:
    mov rdi, 'LOWER'
    call PrintLn
    ; SUBTRACT TO GET UPPERCASE (from lower)
    sub r9b, 32 ; lower to upper 
    sub r9b, 17 ; upper to num
    jmp .AsciiLooped

.AsciiLessThanOrEqualTo9:
    cmp r9b, 0
    jl .AsciiLessThan0 ; CHECK IF NOT NUM
    mov rdi, 'IS NUM'
    call PrintLn
    jmp .AsciiLooped

.AsciiLessThan0:
    mov rdi, 'INVALID'
    call PrintLn
    jmp .AsciiFailed

.AsciiLooped: 
    mov [rbp+r10], r9b
    jmp .AsciiStartLoop

.AsciiDone:
    ; idk
    mov rdi, 'RAW '
    call Print
    mov rdi, 'X POS: '
    call Print
    mov dil, [rbp-3]
    add dil, 48
    call PrintLn

    mov rdi, 'RAW '
    call Print
    mov rdi, 'Y POS: '
    call Print
    mov dil, [rbp-2]
    add dil, 48
    call PrintLn


    ;mov rdi, xPos
    ;mov rsi, yPos
    ;mov rdx, char
    ;call SetTile
    jmp .CheckForGravity
    
.CheckForGravity:
    call ApplyGravityToTile
    cmp rax, 0
    jl .GravityFailed

.ParseSuccess:
    mov rax, 1
    ret

.AsciiFailed:
    mov rax, 0
    ret

.GravityFailed:
    mov rax, 0
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
    mov rdi, 'NEW LINE'
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
    movzx rdi, byte [rbp-32] ; get the 8 bytes from rbp
    mov [rax], byte dil ; write the character to the tile position
    
    
    ret


GetTile:
    ; (xPos) Index of tile, will be 0,1,2,3,etc - RDI 
    ; (yPos) Row - RSI
    ; RETURN: pointer to correct tile (char in string)
    
    push r12
    push r13
    push r14
    push r15
   
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
    mov rax, rcx ; RETURN POINTER TO THE CORRECT TILE


    pop r15
    pop r14
    pop r13
    pop r12

    ret


PrintBoard:
    ;mov rdi, [msgBoardPos]
    ;call PrintLn

    mov rdi, ''
    call PrintLn

    ; rax / rbx
    ; char per row / 3
    movzx rax, byte [rbp-48] 
    dec rax
    mov r14, rax ; r14 holds number of chars

    xor rdx, rdx
    mov rbx, 3
    div rbx
    mov r15, rax ; r15 holds number of tiles

    mov r13, 0
    cmp r15, 9
    jg .UseLettersInsteadOfNumbers
    ; IF MORE THAN 10 TILES - USE LETTERS INSTEAD OF NUMBER
    mov r14, 48 ; use Numbers as index 
    jmp .StartBoardHeaderLoop

.UseLettersInsteadOfNumbers:
    mov r14, 65

.StartBoardHeaderLoop:
    cmp r13, r15
    jg .EndBoardHeaderLoop
    mov rdi, ' '
    call Print

    mov rdi, r13
    ;add rdi, 65 ; TO USE LETTERS AS INDEX
    add rdi, r14 ; TO USE NUMBERS AS INDEX  
    
    call Print
    mov rdi, ' '
    call Print
    inc r13
    jmp .StartBoardHeaderLoop

.EndBoardHeaderLoop:
    mov rdi, ''
    call PrintLn

    ; Result: RAX = 6 (quotient), RDX = 1 (remainder)


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



