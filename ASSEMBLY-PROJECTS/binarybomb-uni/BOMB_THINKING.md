# Running bomb safely:
```
gdb bomb
break trigger_bomb_now
run (do not run on **stream**!!)

# OR TO DISSASSEMBLE
# disass (functionName)
disass bombphase_1
```



---



## using GDB
```bash
gdb bomb
break trigger_bomb_now
run

# OR TO DISSASSEMBLE
# disass (functionName)
disass bombphase_1
```
## C Code
```c
code
```

## bombphase_1()
`rdi` contains our input, and we check if each byte is equal to:

| `hex(%rdi)` | hex  | decimal | char |
| :---------: | :--: | :-----: | :--: |
|     0x0     | 0x66 |   102   |  f   |
|     0x1     | 0x58 |   88    |  X   |
|     0x2     | 0x65 |   101   |  e   |
|     0x3     | 0x26 |   38    |  &   |
|     0x4     | 0x56 |   86    |  V   |
**PASSWORD (easy)** = `fXe&V`

### HARD VERSION
`<+31>` contains a `je`  instead of `jne` so we need to NOT use `V` at that byte to keep checks ongoing

| `hex(%rdi)` | hex  | decimal | char |
| :---------: | :--: | :-----: | :--: |
|     0x0     | 0x66 |   102   |  f   |
|     0x1     | 0x58 |   88    |  X   |
|     0x2     | 0x65 |   101   |  e   |
|     0x3     | 0x26 |   38    |  &   |
|     0x4     | 0x56 |   86    |  V   |
|             |      |         |      |
- 0x2b
- 0x13
- 0x12
- 0x27

Dissassemble main


### Disassemble
```
Dump of assembler code for function bombphase_1:
   0x00000000004014dc <+0>:     sub    $0x8,%rsp
   0x00000000004014e0 <+4>:     cmpb   $0x66,(%rdi)
   0x00000000004014e3 <+7>:     jne    0x401526 <bombphase_1+74>
   0x00000000004014e5 <+9>:     cmpb   $0x58,0x1(%rdi)
   0x00000000004014e9 <+13>:    jne    0x401526 <bombphase_1+74>
   0x00000000004014eb <+15>:    cmpb   $0x26,0x3(%rdi)
   0x00000000004014ef <+19>:    jne    0x401526 <bombphase_1+74>
   0x00000000004014f1 <+21>:    cmpb   $0x65,0x2(%rdi)
   0x00000000004014f5 <+25>:    jne    0x401526 <bombphase_1+74>
   0x00000000004014f7 <+27>:    cmpb   $0x56,0x4(%rdi)
   0x00000000004014fb <+31>:    je     0x401534 <bombphase_1+88>
   
   0x00000000004014fd <+33>:    cmp    %sil,0x2b(%rdi)
   0x0000000000401501 <+37>:    jne    0x401526 <bombphase_1+74>
   0x0000000000401503 <+39>:    cmp    %cl,0x13(%rdi)
   0x0000000000401506 <+42>:    jne    0x401526 <bombphase_1+74>
   0x0000000000401508 <+44>:    movzbl 0x12(%rdi),%edx
   0x000000000040150c <+48>:    movzbl 0x27(%rdi),%eax
   0x0000000000401510 <+52>:    cmp    %al,%dl
   0x0000000000401512 <+54>:    je     0x401526 <bombphase_1+74>
   0x0000000000401514 <+56>:    movsbl %dl,%ecx
   0x0000000000401517 <+59>:    movsbl %al,%eax
   0x000000000040151a <+62>:    lea    0x3(%rax),%edx
   0x000000000040151d <+65>:    mov    $0x1,%eax
   0x0000000000401522 <+70>:    cmp    %edx,%ecx
   0x0000000000401524 <+72>:    je     0x401539 <bombphase_1+93>
   0x0000000000401526 <+74>:    callq  0x401e6a <trigger_bomb_now>
   0x000000000040152b <+79>:    mov    $0xffffffffd9d580af,%rax
   0x0000000000401532 <+86>:    jmp    0x401539 <bombphase_1+93>
   0x0000000000401534 <+88>:    mov    $0x0,%eax
   0x0000000000401539 <+93>:    add    $0x8,%rsp
   0x000000000040153d <+97>:    retq
```

## bombphase_2()
`rdi` contains our input, in line `<+5>` we move `rdi` into `rbx`.

| `hex(%rdi)` | hex  | decimal | char |
| :---------: | :--: | :-----: | :--: |
|     0x0     | 0x66 |   102   |  f   |
|     0x1     | 0x58 |   88    |  X   |
|     0x2     | 0x65 |   101   |  e   |
|     0x3     | 0x26 |   38    |  &   |
|     0x4     | 0x56 |   86    |  V   |
**PASSWORD (easy)** = `accountant`
**PASSWORD (hard)** = `accountant1234567890123456789`

## Dissassemble
```
Dump of assembler code for function bombphase_2:
   0x00000000004015fa <+0>:     push   %rbx
allocate 16 bytes onto the stack
   0x00000000004015fb <+1>:     sub    $0x10,%rsp
   0x00000000004015ff <+5>:     mov    %rdi,%rbx
littleendian 'accounta' (doesnt give full word)
   0x0000000000401602 <+8>:     movabs $0x61746e756f636361,%rax
   0x000000000040160c <+18>:    mov    %rax,(%rsp)
   movw = mov 16 bits (2 bytes) 'nt', we go into 0x8(%rsp) since 'accounta' is already in rsp
   0x0000000000401610 <+22>:    movw   $0x746e,0x8(%rsp)
   movb = mov 8 bits (1 byte)
   0x0000000000401617 <+29>:    movb   $0x0,0xa(%rsp)
   0x000000000040161c <+34>:    mov    $0xa,%edx
   
   mov into rsi the the stack pointer
   0x0000000000401621 <+39>:    mov    %rsp,%rsi
   0x0000000000401624 <+42>:    callq  0x401580 <my_strncmp>
   0x0000000000401629 <+47>:    test   %eax,%eax
   0x000000000040162b <+49>:    jne    0x40164b <bombphase_2+81>
   
   0x000000000040162d <+51>:    mov    $0x0,%eax
   0x0000000000401632 <+56>:    cmpb   $0x0,0xa(%rbx)
   0x0000000000401636 <+60>:    je     0x401657 <bombphase_2+93>
   0x0000000000401638 <+62>:    mov    %rbx,%rdi
   0x000000000040163b <+65>:    callq  0x4015dc <my_strlen>
   0x0000000000401640 <+70>:    cmp    $0x1d,%eax
   0x0000000000401643 <+73>:    sete   %al
   0x0000000000401646 <+76>:    movzbl %al,%eax
   0x0000000000401649 <+79>:    jmp    0x401657 <bombphase_2+93>
   0x000000000040164b <+81>:    callq  0x401e6a <trigger_bomb_now>
   0x0000000000401650 <+86>:    mov    $0xffffffffd9d580af,%rax
   0x0000000000401657 <+93>:    add    $0x10,%rsp
   0x000000000040165b <+97>:    pop    %rbx
   0x000000000040165c <+98>:    retq
```