section	.text
   global _start	 ;must be declared for linker (gcc)
	
_start:	         ;tell linker entry point
   ;mov ebx,4
   ;mov eax,1
   ;int 0x80 ; SAME AS syscall

   ;mov	edx,len  ;message length
   ;mov	ecx,msg  ;message to write
   ;mov	ebx,1    ;file descriptor (stdout)
   ;mov	eax,4    ;system call number (sys_write)
   ;int	0x80     ;call kernel
	
   mov edx,0xa
   mov ecx,msg_start
   mov eax,4
   syscall

   mov edx,0xa
   mov ecx,msg_mid
   mov eax,4
   syscall

   mov edx,0xa
   mov ecx,msg_end
   mov eax,4
   syscall

   


   mov	edx,sizeOfStars    ;message length
   mov	ecx,stars   ;message to write
   mov	ebx,1    ;file descriptor (stdout)
   mov	eax,4    ;system call number (sys_write)
   int	0x80     ;call kernel
	
   mov	eax,1    ;system call number (sys_exit)
   int	0x80     ;call kernel
	
section	.data
stars times 0xc db '*',0xa
sizeOfStars equ $ - stars 

msg db 'Displaying more stars',0xa ;a message
len equ $ - msg  ;length of message

msg_start db 'Displaying '
msg_mid db sizeOfStars
msg_end db ' stars',0xa

;msg_full db msg_start, msg_mid, msg_end
;msg_size equ $ - msg_full
