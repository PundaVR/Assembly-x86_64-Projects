section .text
   global _start   
	
_start:	
   mov  eax, 3       ; Number of bytes to sum 
   mov  ebx, 0       ; Accumulator for sum
   mov  ecx, x       ; Pointer to current byte

top:  
   movzx edx, byte [ecx] ; Read byte cleanly (zero-extended)
   add   ebx, edx
   inc   ecx         ; Move pointer to next element
   dec   eax         ; Decrement counter
   jnz   top         ; Loop until eax == 0

done: 
   ; --- Convert EBX (sum) into ASCII string backwards ---
   mov  eax, ebx     ; Move sum into EAX for division
   mov  edi, sum_end ; Start pointer at the newline byte

   ; Append newline first at the end
   mov  byte [edi], 0xA 
   dec  edi          ; Move pointer left

convert_loop:
   mov  edx, 0       ; Clear EDX before division (EDX:EAX / 10)
   mov  ecx, 10
   div  ecx          ; EAX = quotient, EDX = remainder

   add  dl, '0'      ; Convert remainder (single digit) to ASCII
   mov  [edi], dl    ; Store character into buffer
   dec  edi          ; Move buffer pointer 1 byte left

   test eax, eax     ; Is quotient (EAX) == 0?
   jnz  convert_loop ; If not 0, loop to get next digit

   inc  edi          ; EDI now points to the first digit of our string

display:
   ; --- Calculate string length ---
   mov  edx, sum_end ; EDX = address of sum_end
   sub  edx, edi     ; Difference gives exact length (including '\n')
   inc  edx          ; Include the 0xA byte in total count

   mov  ecx, edi     ; ECX = start address of our formatted number
   mov  ebx, 1       ; stdout
   mov  eax, 4       ; sys_write
   int  0x80       
	
   mov  eax, 1       ; sys_exit
   int  0x80       

section .data
global x
x:    
   db  25, 42, 35   ; Sum = 102

section .bss
   ; Reserve a 16-byte buffer for the converted string
   sum_buf resb 15
   sum_end resb 1