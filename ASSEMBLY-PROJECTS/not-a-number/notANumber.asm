DEFAULT REL

section .bss
    userInput resb 8

section .data
    testMsg db 'TEST '
    len_testMsg equ $ - testMsg

    userMsg db 'Provide a number: '
    len_userMsg equ $ - userMsg

    exitMsg db 'Exiting program', 10
    len_exitMsg equ $ - exitMsg

    lineBreakMsg db 10, '======', 10
    len_lineBreakMsg equ $ - lineBreakMsg

    brotato db 'woah'

section .text
    global _start

_start:

    ; store userInput in memory
    push rbp ; save the old base pointer (extern program called)
    mov rbp, rsp ; RBP takes the current snapshot of RSP
    sub rsp, 32 ; using rsp instead of rbp because that worked earlier
    
    ; variables we need (use first 8 bytes of stack for those)
    mov byte [rbp-32], 10 ; newline character
    mov byte [rbp-31], 1; isNumber T/F - default true
    ; r12 IS ALWAYS USED FOR DEBUG FUNCTION Args1
    ; r13

    mov rdx, len_userMsg
    mov rsi, userMsg
    mov rax, 1
    mov rdi, 1
    syscall

    ; read the input from user
    mov rdx, 8
    mov rsi, userInput
    mov rax, 0
    mov rdi, 0
    syscall

    ; store user input
    mov r13, [userInput] ; putting raw userInput value into r13
    mov [rbp-8], r13;bpl, r13b       ; moving r13 pointer into raw value of rbp's first byte
    

    ; print user input
    mov rdx, 8
    mov rsi, userInput
    mov rax, 1
    mov rdi, 1
    syscall

    ; store custom message
    mov r12, 'ONE 111';brotato

    call printLineBreak ;===============

    call printDebug
    call printInput
    
    call printLineBreak ;===============

    call verifyInput

    jmp exit


verifyInput:
    

    ; start the loop
    mov r14, -8  ; must be -8, or we need to use `neg r15`
    ;neg r15
    mov r12, 'LOOP ' ; debug text for loop

    call parseLoop
    call printLineBreak ;===============

    ret

parseLoop:
    ; ARGUMENTS:
    ; r14 is our loop counter
    ; r15 is condition
    ; r16 idk
    ;mov [r12+5], byte r15b ;fuckthis
    
    ;slopcode
    lea r11, [r14 + 8]           ; Convert -8..-1 into 0..7 (r11 = r14 + 8)
    add r11, '0:'                 ; Convert integer to ASCII ('0', '1', '2'...)
    shl r11, 40                  ; Shift left to 6th byte position (offset 5) - 40 bits, which is 5 bytes
    mov r12, 'LOOP '             ; Start with fresh base 'LOOP '
    or  r12, r11                 ; Merge to create 'LOOP 0', 'LOOP 1', etc.

    movzx r11, byte [rbp + r14]
    shl r11, 56
    or r12, r11
    
    movzx r15, byte [rbp + r14] ; R15 HOLDS THE CHARACTER WE ARE CHECKING
    call printDebug
    

    

    mov r12, 'FUCKAAAA'
    call printDebug
    ; CHECK IF NUMERICAL
    sub r15, '0'
    cmp r15, 0
    jb notNumber


    mov r12, 'FUCKBBBB'
    call printDebug


    cmp r15, 9
    ja notNumber
    
    mov r12, 'FUCKCCCC'
    call printDebug


; CHECK IF END OF userInput
    
    mov r12, 'FUCKDDDD'
    call printDebug

inc r14
    cmp r14, 0 ; use r15 instead to check for when string ends (0 == 0x00)
    jne parseLoop
    je finishLoop ; skip numerical check




   

finishLoop:
    ; IF FINISHED
    mov r12, 'LOOP FIN'
    call printDebug

; if isValid == 1 : 
    cmp [rbp-31], 1
    je .ifBranch
    jne .elseBranch
.ifBranch:
    mov r12, 'IS A NUM'
    call printDebug
    call printLineBreak
    jmp .endif
.elseBranch:
    mov r12, 'NOT NUM!'
    jmp .endif

.endif:
    call printLineBreak
    call printDebug
    
    jmp exit;ret
    ret

notNumber:
    mov r12, 'FUCKXXXX'
    call printDebug

    
   
    cmp byte [rbp + r14], 0x0A ; check if terminator character
    je finishLoop
    jne .isInvalid ;might not need this since codeflow is right below
    

 
    jmp finishLoop;parseLoop
    ret

.isInvalid:
    
    mov r12, 'FUCKZZZZ'
    call printDebug


    mov [rbp-31], 0
    mov r12, 'INVALID!'
    call printDebug
    jmp finishLoop


printDebug: 
    ; r12 - REGISTER 12 CONTROLS DEBUG MESSAGE
    ; TO STORE TEXT TO PRINT (8 bytes) ADD TO r12
    ; mov r12, 'woahWOAH';brotato
    ; mov [rbp-16], r12

    ; Prints 'TEST '
    mov rdx, len_testMsg
    mov rsi, testMsg
    mov rax, 1
    mov rdi, 1
    syscall

    

    ; PRINT Arg1 (content in R12)
    mov [rbp-16], r12

    mov rdx, 8
    lea rsi, [rbp-16];r12 ; using r12
    mov rax, 1
    mov rdi, 1
    syscall

    ; we call this near the start of the program:
    ; mov byte [rbp-1], 10 (it stores 0x0A on stack) newline char exists 

    mov rdx, 1
    lea rsi, [rbp-32]
    mov rax, 1
    mov rdi, 1
    syscall
    

    
    
    ; final output: 'TEST [arg1]'
    ret


printInput:
    mov rdx, 8
    lea rsi, [rbp-8] ; making this `[rbp+8]` instead of `rbp` - got rid of random symbols
    mov rax, 1
    mov rdi, 1
    syscall
    ret

printLineBreak:
    mov rdx, len_lineBreakMsg
    mov rsi, lineBreakMsg
    mov rax, 1
    mov rdi, 1
    syscall
    ret 



exit:
    mov rsp, rbp ; RSP goes back to the original address (which rbp holds)
    pop rbp ; restore caller's RBP (which we pushed at _start)
    
    
    ;we dont actually need to do this, since `mov rsp, rbp` resets the stack 
    ;add rsp, 32 ; adding back 16 byes since we did 'sub' earlier in code
    
    ; clearing up stack
    
    ; Prints out 'Exiting program'
    mov rdx, len_exitMsg 
    mov rsi, exitMsg
    mov rax, 1
    mov rdi, 1
    syscall
    

    mov rax, 60             ; syscall number for sys_exit
    mov rdi, 0              ; exit code 0
    syscall

