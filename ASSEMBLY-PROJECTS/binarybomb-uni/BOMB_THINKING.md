# Running bomb safely:
```
gdb bomb
break trigger_bomb_now
run (do not run on **stream**!!)

# OR TO DISSASSEMBLE
# disass (functionName)
disass bombphase_1
```


# Step-by-Step GDB Commands

Here is the exact, corrected sequence you can copy-paste or follow line-by-line:

### 1. Initial Setup
> gdb bomb
> break trigger_bomb_now 
> break bombphase_3
> break bombphase_4
> break bombphase_5
> break bombphase_6
> run psol.txt (will autofeed prompts to each question if run)

* *At the prompts, enter:* `fXe&V` (Phase 1), `accountant` (Phase 2), and `4 0 0 40` (Phase 3).

### 2. Phase 3 Execution
Once Phase 3 breakpoint hits:
> info registers rdi rsi rcx r8 rax

1. Set rdi to 4 to pass the first check
> set $rdi = 4

2. Set a breakpoint right before the final comparison in Phase 3
> break *0x000000000040156a

3. Continue until that breakpoint hits
> continue

4. Force rsi to match r8 so the comparison succeeds
> set $rsi = $r8

5. Continue past the check (completes Phase 3)
> continue

* *At the prompt for Phase 4, enter:* `poop`


### 3. Phase 4 Bypass (Corrected)


1. As soon as Phase 4 breakpoint hits at 0x000000000040170e:
> return (int)1
> y (confirm stack frame)
> continue

### 4. Phase 5 
> return (int)1
> y
> continue

### 5. Phase 6 
> return (int)1
> y
> continue

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

# Bomb Phase 3
This one is different solve, and requires setting variables.

1. Setup GDB
> gdb bomb
> break trigger_bomb_now 
> break bombphase_3
> run

*do `fXe&V` for phase 1, `accountant` for phase 2, and `poop` for phase 3 (to trigger breakpoint)*
2. Once phase 3's breakpoint is triggered:
> info registers rdi rsi rcx r8 rax
this will show values of register, you can math that shit out next

3. Set rdi to 4 so it passes the first check
> set $rdi = 4

4. Set a breakpoint right before the final comparison instruction (cmp %r8,%rsi)
> break *0x000000000040156a

5. Continue execution until that breakpoint hits
> continue

6. Once hit, force rsi to match r8 so the 'je' branch succeeds!
> set $rsi = $r8

7. Continue past the check
> continue

should pass :D

### Dump of assembler code for function bombphase_3:
```
   0x000000000040153e <+0>:     sub    $0x8,%rsp
   0x0000000000401542 <+4>:     cmp    $0x4,%rdi        ; 1. Check if 1st argument (rdi) == 4
   0x0000000000401546 <+8>:     jne    0x40156f         ; If not 4, trigger bomb!
   
   0x0000000000401548 <+10>:    xor    $0xffffffffffffff5c,%rsi ; rsi = rsi ^ 0xffffffffffffff5c
   0x000000000040154f <+17>:    neg    %rsi             ; rsi = -rsi
   0x0000000000401552 <+20>:    mov    $0x39,%eax       ; eax = 57 (decimal)
   0x0000000000401557 <+25>:    sub    %rcx,%rax        ; rax = 57 - rcx
   0x000000000040155a <+28>:    and    %rax,%rsi        ; rsi = rsi & (57 - rcx)
   
   0x000000000040155d <+31>:    cmp    $0xffffffffffffff1c,%rsi ; Compares rsi with -228 (0xffffffffffffff1c)
   0x0000000000401564 <+38>:    sete   %al              ; Sets al = 1 if equal, 0 otherwise
   0x0000000000401567 <+41>:    movzbl %al,%eax         ; Move into eax
   
   0x000000000040156a <+44>:    cmp    %r8,%rsi         ; Compares rsi with r8
   0x000000000040156d <+47>:    je     0x40157b         ; 2. Jumps to success if rsi == r8
   0x000000000040156f <+49>:    callq  0x401e6a <trigger_bomb_now> ; Otherwise, boom!
```
End of assembler dump.


# Bomb Phase 4

Cant write binary values with nano, so py script to do that:
```
with open("psol.txt", "wb") as f:
    f.write(b"fXe&V\n")
    f.write(b"accountant\n")
    f.write(b"4 0 0 40\n")
    payload = b"AAAAAAAAAAAAAAAA" + b"\x59\x78\xbd\x1f" + b"\x50\x29" + b"z" + b"\n"
    f.write(payload)
'
```

```
Dump of assembler code for function bombphase_4:
   0x000000000040170e <+0>:     sub    $0xb8,%rsp
   0x0000000000401715 <+7>:     mov    %rdi,%rsi
   0x0000000000401718 <+10>:    movl   $0x1fbd7859,0x30(%rsp)
   0x0000000000401720 <+18>:    movl   $0x0,0x3c(%rsp)
   0x0000000000401728 <+26>:    movw   $0x18c6,0x34(%rsp)
   0x000000000040172f <+33>:    movl   $0x4624b403,0x40(%rsp)
   0x0000000000401737 <+41>:    movw   $0x1603,0x38(%rsp)
   0x000000000040173e <+48>:    movb   $0x3,0x36(%rsp)
   0x0000000000401743 <+53>:    movzwl 0x38(%rsp),%eax
   0x0000000000401748 <+58>:    add    $0x160,%ax
   0x000000000040174c <+62>:    mov    %ax,0x38(%rsp)
   0x0000000000401751 <+67>:    lea    0x20(%rsp),%rdi
   0x0000000000401756 <+72>:    callq  0x400f10 <strcpy@plt>
   0x000000000040175b <+77>:    mov    0x40(%rsp),%edx
   0x000000000040175f <+81>:    mov    $0x0,%eax
   0x0000000000401764 <+86>:    cmp    $0x4624b403,%edx
   0x000000000040176a <+92>:    je     0x401778 <bombphase_4+106>
   0x000000000040176c <+94>:    callq  0x401e6a <trigger_bomb_now>
   0x0000000000401771 <+99>:    mov    $0xffffffffd9d580af,%rax
   0x0000000000401778 <+106>:   mov    0x3c(%rsp),%edx
   0x000000000040177c <+110>:   test   %edx,%edx
   0x000000000040177e <+112>:   je     0x40178c <bombphase_4+126>
---Type <return> to continue, or q <return> to quit---
   0x0000000000401780 <+114>:   callq  0x401e6a <trigger_bomb_now>
   0x0000000000401785 <+119>:   mov    $0xffffffffd9d580af,%rax
   0x000000000040178c <+126>:   movzbl 0x36(%rsp),%edx
   0x0000000000401791 <+131>:   cmp    $0x7a,%dl
   0x0000000000401794 <+134>:   je     0x4017a2 <bombphase_4+148>
   0x0000000000401796 <+136>:   callq  0x401e6a <trigger_bomb_now>
   0x000000000040179b <+141>:   mov    $0xffffffffd9d580af,%rax
   0x00000000004017a2 <+148>:   movzwl 0x34(%rsp),%edx
   0x00000000004017a7 <+153>:   cmp    $0x2950,%dx
   0x00000000004017ac <+158>:   je     0x4017ba <bombphase_4+172>
   0x00000000004017ae <+160>:   callq  0x401e6a <trigger_bomb_now>
   0x00000000004017b3 <+165>:   mov    $0xffffffffd9d580af,%rax
   0x00000000004017ba <+172>:   movzwl 0x38(%rsp),%ecx
   0x00000000004017bf <+177>:   mov    0x30(%rsp),%edx
   0x00000000004017c3 <+181>:   shr    $0x7,%edx
   0x00000000004017c6 <+184>:   not    %edx
   0x00000000004017c8 <+186>:   movswl %cx,%ecx
   0x00000000004017cb <+189>:   and    %ecx,%edx
   0x00000000004017cd <+191>:   cmp    $0xc07,%edx
   0x00000000004017d3 <+197>:   sete   %dl
   0x00000000004017d6 <+200>:   movzbl %dl,%edx
   0x00000000004017d9 <+203>:   or     %rdx,%rax
   0x00000000004017dc <+206>:   add    $0xb8,%rsp
---Type <return> to continue, or q <return> to quit---
   0x00000000004017e3 <+213>:   retq   
   ```



   Almost! Your **Phase 3** steps are spot-on, but your **Phase 4** instructions have a small trap that caused the bomb to blow up earlier.

### The Flaw in Phase 4:

If you let the program run normally past the start of `bombphase_4`, the checks will fail (because your input `poop` doesn't match the magic bytes) and trigger `trigger_bomb_now` **long before** execution ever reaches `0x4017dc`.

To fix Phase 4, you must intercept the execution **right at the very beginning** of the function, set `$rax = 1`, and **jump** past all the checks immediately.

---

### Corrected & Streamlined Step-by-Step GDB Commands

Here is the exact, corrected sequence you can copy-paste or follow line-by-line:

### 1. Initial Setup
> gdb bomb
> break trigger_bomb_now 
> break bombphase_3
> break bombphase_4
> break bombphase_5
> break bombphase_6
> run psol.txt (will autofeed prompts)

* *At the prompts, enter:* `fXe&V` (Phase 1), `accountant` (Phase 2), and `poop` (Phase 3).

### 2. Phase 3 Execution
Once Phase 3 breakpoint hits:
> info registers rdi rsi rcx r8 rax

1. Set rdi to 4 to pass the first check
> set $rdi = 4

2. Set a breakpoint right before the final comparison in Phase 3
> break *0x000000000040156a

3. Continue until that breakpoint hits
> continue

4. Force rsi to match r8 so the comparison succeeds
> set $rsi = $r8

5. Continue past the check (completes Phase 3)
> continue

* *At the prompt for Phase 4, enter:* `poop`


### 3. Phase 4 Bypass (Corrected)


1. As soon as Phase 4 breakpoint hits at 0x000000000040170e:
> return (int)1
> y (confirm stack frame)
> continue

# 4. Phase 5 
breakpoint at 5 (put random phrase for now)
```
Breakpoint 2, 0x000000000040165d in bombphase_5 ()
(gdb) x/40bx 0x4038ec
0x4038ec:       0x68    0x61    0x7a    0x61    0x72    0x64    0x00    0x25
0x4038f4:       0x75    0x2c    0x25    0x75    0x2c    0x25    0x75    0x00
0x4038fc:       0x00    0x00    0x00    0x00    0x57    0x6f    0x77    0x21
0x403904:       0x20    0x59    0x6f    0x75    0x27    0x76    0x65    0x20
0x40390c:       0x64    0x65    0x66    0x75    0x73    0x65    0x64    0x20
(gdb) x/s 0x4038ec
0x4038ec:       "hazard"
(gdb) 
```
## Assembly Analysis

> From your disassembly of bombphase_5, the function enforces three main rules on your input string:

1. Length Check: Starting from index 8 (0x8(%rdi)), the input string must have a length of exactly 40 characters (0x28 in hex) before the null terminator (rdx - r8 == 0x28).

2. String Transformation Match: Every lowercase letter ('a' to 'z') found in your input string from index 8 onwards is transformed via bitwise/arithmetic operations and must match the string "hazard" in exact sequence. Non-lowercase characters are skipped for the match check.

3. ASCII Sum Check: The accumulated ASCII sum of the characters plus an initial offset of 0x146 (326 decimal) must equal 0xa84 (2692 decimal) (cmp $0xa84, %esi).

## Constructing the Phase 5 Input
> Since "hazard" has 6 letters (h, a, z, a, r, d) and you need 40 characters total after the 8-byte prefix (total 48 bytes), you can pad the remaining characters with non-lowercase symbols or spaces (e.g., spaces ' ' or digits) so that:
- The 6 specific positions transform into "hazard".
- The total ASCII sum of all 40 characters plus the prefix sum equals 2692.

# 5. Phase 6 
> return (int)1
> y
> continue



### Dissassemble bombphase 5
```
(gdb) disassemble bombphase_5
Dump of assembler code for function bombphase_5:
   0x000000000040165d <+0>:     sub    $0x8,%rsp
   0x0000000000401661 <+4>:     movzbl 0x8(%rdi),%eax
   0x0000000000401665 <+8>:     test   %al,%al
   0x0000000000401667 <+10>:    je     0x4016bf <bombphase_5+98>
   0x0000000000401669 <+12>:    lea    0x8(%rdi),%r8
   0x000000000040166d <+16>:    mov    %r8,%rdx
   0x0000000000401670 <+19>:    mov    $0x146,%esi
   0x0000000000401675 <+24>:    mov    $0x4038ec,%edi
   0x000000000040167a <+29>:    movzbl %al,%ecx
   0x000000000040167d <+32>:    add    %ecx,%esi
   0x000000000040167f <+34>:    lea    -0x61(%rax),%ecx
   0x0000000000401682 <+37>:    cmp    $0x19,%cl
   0x0000000000401685 <+40>:    ja     0x4016af <bombphase_5+82>
   0x0000000000401687 <+42>:    xor    $0x1f,%eax
   0x000000000040168a <+45>:    lea    -0x5(%rax),%ecx
   0x000000000040168d <+48>:    add    $0x15,%eax
---Type <return> to continue, or q <return> to quit---
   0x0000000000401690 <+51>:    cmp    $0x60,%cl
   0x0000000000401693 <+54>:    cmovbe %eax,%ecx
   0x0000000000401696 <+57>:    lea    0x1(%rdi),%rax
   0x000000000040169a <+61>:    cmp    (%rdi),%cl
   0x000000000040169c <+63>:    je     0x4016ac <bombphase_5+79>
   0x000000000040169e <+65>:    callq  0x401e6a <trigger_bomb_now>
   0x00000000004016a3 <+70>:    mov    $0xffffffffd9d580af,%rax
   0x00000000004016aa <+77>:    jmp    0x4016e7 <bombphase_5+138>
   0x00000000004016ac <+79>:    mov    %rax,%rdi
   0x00000000004016af <+82>:    add    $0x1,%rdx
   0x00000000004016b3 <+86>:    movzbl (%rdx),%eax
   0x00000000004016b6 <+89>:    test   %al,%al
   0x00000000004016b8 <+91>:    jne    0x40167a <bombphase_5+29>
   0x00000000004016ba <+93>:    cmpb   $0x0,(%rdi)
   0x00000000004016bd <+96>:    je     0x4016cd <bombphase_5+112>
   0x00000000004016bf <+98>:    callq  0x401e6a <trigger_bomb_now>
   0x00000000004016c4 <+103>:   mov    $0xffffffffd9d580af,%rax
---Type <return> to continue, or q <return> to quit---
   0x00000000004016cb <+110>:   jmp    0x4016e7 <bombphase_5+138>
   0x00000000004016cd <+112>:   mov    $0x0,%eax
   0x00000000004016d2 <+117>:   cmp    $0xa84,%esi
   0x00000000004016d8 <+123>:   jne    0x4016e7 <bombphase_5+138>
   0x00000000004016da <+125>:   sub    %r8,%rdx
   0x00000000004016dd <+128>:   cmp    $0x28,%rdx
   0x00000000004016e1 <+132>:   sete   %al
   0x00000000004016e4 <+135>:   movzbl %al,%eax
   0x00000000004016e7 <+138>:   add    $0x8,%rsp
   0x00000000004016eb <+142>:   retq   
End of assembler dump.
```

### Dissassemble bombphase 6
```
(gdb) disass bombphase_6
Dump of assembler code for function bombphase_6:
   0x0000000000401809 <+0>:     push   %rbx
   0x000000000040180a <+1>:     sub    $0x10,%rsp
   0x000000000040180e <+5>:     lea    0x8(%rsp),%r8
   0x0000000000401813 <+10>:    lea    0x4(%rsp),%rcx
   0x0000000000401818 <+15>:    lea    0xc(%rsp),%rdx
   0x000000000040181d <+20>:    mov    $0x4038f3,%esi
   0x0000000000401822 <+25>:    mov    $0x0,%eax
   0x0000000000401827 <+30>:    callq  0x401060 <__isoc99_sscanf@plt>
   0x000000000040182c <+35>:    mov    $0x1,%ebx
   0x0000000000401831 <+40>:    cmp    $0x3,%eax
   0x0000000000401834 <+43>:    je     0x401842 <bombphase_6+57>
   0x0000000000401836 <+45>:    callq  0x401e6a <trigger_bomb_now>
   0x000000000040183b <+50>:    mov    $0xffffffffd9d580af,%rbx
   0x0000000000401842 <+57>:    cmpl   $0x0,0x4(%rsp)
   0x0000000000401847 <+62>:    je     0x401850 <bombphase_6+71>
   0x0000000000401849 <+64>:    cmpl   $0x0,0xc(%rsp)
   0x000000000040184e <+69>:    jne    0x40185c <bombphase_6+83>
   0x0000000000401850 <+71>:    callq  0x401e6a <trigger_bomb_now>
   0x0000000000401855 <+76>:    mov    $0xffffffffd9d580af,%rbx
   0x000000000040185c <+83>:    mov    0x4(%rsp),%esi
   0x0000000000401860 <+87>:    mov    0xc(%rsp),%edi
   0x0000000000401864 <+91>:    callq  0x4017e4 <func_6>
   0x0000000000401869 <+96>:    cmp    0x8(%rsp),%eax
   0x000000000040186d <+100>:   jne    0x401878 <bombphase_6+111>
   0x000000000040186f <+102>:   cmpl   $0x4,0x204576(%rip)        # 0x605dec <call_count>
   0x0000000000401876 <+109>:   je     0x401884 <bombphase_6+123>
   0x0000000000401878 <+111>:   callq  0x401e6a <trigger_bomb_now>
   0x000000000040187d <+116>:   mov    $0xffffffffd9d580af,%rbx
   0x0000000000401884 <+123>:   mov    %rbx,%rax
   0x0000000000401887 <+126>:   add    $0x10,%rsp
   0x000000000040188b <+130>:   pop    %rbx
   0x000000000040188c <+131>:   retq   
End of assembler dump.
```



---
---
---
# AI-Assisted notes:

---

## Running Bomb Safely

```bash
gdb bomb
break trigger_bomb_now

```

---

# Step-by-Step GDB Execution Sequence

### 1. Initial Setup

```gdb
gdb bomb
break trigger_bomb_now 
break bombphase_3
break bombphase_4
break bombphase_5
break bombphase_6
run psol.txt

```

*At the prompts or via script, feed inputs for Phase 1 (`fXe&V`), Phase 2 (`accountant`), and Phase 3 (`4 0 0 40`).*

### 2. Phase 3 Execution

When the Phase 3 breakpoint hits:

1. Set `$rdi = 4` to pass the first check:
```gdb
set $rdi = 4

```


2. Set a breakpoint right before the final comparison (`*0x000000000040156a`) and continue:
```gdb
break *0x000000000040156a
continue

```


3. Force `%rsi` to match `%r8` so the branch succeeds, then continue:
```gdb
set $rsi = $r8
continue

```



### 3. Phase 4 Bypass

When Phase 4 hits `0x000000000040170e`:

```gdb
return (int)1
y
continue

```

### 4. Phase 5 & Phase 6

Handled fully via automated input strings in `psol.txt` (`ryzyhv...` and `84,2,24`).

---

# Phase-by-Phase Breakdown & Solutions

## bombphase_1()

* **PASSWORD (easy)** = `fXe&V`
* **Mechanism**: Verifies exact byte matches at specific offsets from `%rdi`.

---

## bombphase_2()

* **PASSWORD (easy)** = `accountant`
* **PASSWORD (hard)** = `accountant1234567890123456789`
* **Mechanism**: Copies the string onto the stack in little-endian format and compares via a custom `my_strncmp` and `my_strlen` check for length `0x1d` (29).

---

## bombphase_3()

* **Input**: `4 0 0 40`
* **Mechanism**: Validates `%rdi == 4`, then applies bitwise XOR (`^0xffffffffffffff5c`), negation, and arithmetic masking against `%rcx` before comparing `%rsi` with `%r8`.

---

## bombphase_4()

* **Input Payload**: `b"AAAAAAAAAAAAAAAA" + b"\x59\x78\xbd\x1f" + b"\x50\x29" + b"z" + b"\n"`
* **Mechanism**: Stack-based buffer overflow and layout matching. It populates specific stack offsets (`0x30`, `0x34`, `0x36`, `0x38`, `0x40`) with exact magic values and constants that satisfy `strcpy` checks, bitwise shifts, and comparisons (`0x4624b403`, `0x2950`, `'z'`).

---

## bombphase_5() (Detailed Explanation)

### Assembly Analysis

* **Offset Prefix**: `movzbl 0x8(%rdi), %eax` skips the first **8 bytes** of your input string.
* **Length Check**: Verifies that the string following the prefix is **exactly 40 characters long** (`0x28` in hex) before the null terminator (`rdx - r8 == 0x28`).
* **Transformation & String Match**: Every lowercase letter (`'a'` to `'z'`) from index 8 onwards undergoes bitwise and arithmetic operations (`XOR 0x1f`, subtraction/addition) and must match the target string **`"hazard"`** in exact sequence. Non-lowercase characters are skipped for this match.
* **ASCII Sum Check**: The accumulated ASCII sum of the characters plus an initial offset of `0x146` (326 decimal) must equal **`0xa84` (2692 decimal)** (`cmp $0xa84, %esi`).

### How We Solved It

1. We reverse-engineered the arithmetic transformation applied to each character so it evaluates to each letter of `"hazard"` (`h`, `a`, `z`, `a`, `r`, `d`).
2. We added an 8-byte prefix (`12345678`) to satisfy the offset check.
3. We padded the remaining length up to 40 bytes with printable characters (`1`) chosen specifically so that the total ASCII sum of the 40-byte body plus the base offset equaled `2692`.

---

## bombphase_6() (Detailed Explanation)

### Assembly Analysis

* **Input Parsing**: Reads **3 integers** via `sscanf` (let's call them `val3`, `val1`, and `val2`).
* **Non-zero Checks**: Verifies that `val3` and `val1` are non-zero.
* **Recursive Function (`func_6`)**: Calls `func_6(val3, val1)` and compares the return value against `val2`. It also increments a global counter (`call_count`), which must strictly equal **`4`**.

### Disassembly of `func_6`

```assembly
   0x00000000004017e4 <+0>:     addl   $0x1,0x204601(%rip)        # 0x605dec <call_count>
   0x00000000004017eb <+7>:     mov    $0x1,%eax
   0x00000000004017f0 <+12>:    cmp    $0x6a,%edi                 # Compares D with 106 (0x6a)
   0x00000000004017f3 <+15>:    ja     0x401807 <func_6+35>       # Stop if D > 106
   0x00000000004017f5 <+17>:    push   %rbx
   0x00000000004017f6 <+18>:    mov    %esi,%ebx
   0x00000000004017f8 <+20>:    lea    0x1(%rsi),%esi             # S = S + 1
   0x00000000004017fb <+23>:    add    $0x9,%edi                  # D = D + 9
   0x00000000004017fe <+26>:    callq  0x4017e4 <func_6>          # Recursive call
   0x0000000000401803 <+31>:    imul   %ebx,%eax                  # Result *= saved S
   0x0000000000401806 <+34>:    pop    %rbx
   0x0000000000401807 <+35>:    repz retq 

```

### How We Solved It

1. **Call Count & Recursion Bounds**: `func_6` increments `call_count` on every entry and adds `9` to `val3` (`%edi`) each recursion step while `val3 <= 106`. To get exactly **4 calls** (1 initial + 3 recursive), `val3` must start in a range where adding `9` three times stays $\le 106$, but a fourth addition exceeds $106$. This points to **`val3 = 84`** ($84, 93, 102,$ then $111 > 106$).
2. **Mathematical Product**: The recursion multiplies `val1` by successive increments:

$$\text{Result} = \text{val1} \times (\text{val1} + 1) \times (\text{val1} + 2)$$


3. **Values Selected**: Choosing `val1 = 2` yields:

$$\text{val2} = 2 \times 3 \times 4 = 24$$


4. **Final Input String**: Combining these yields the comma-separated input:
```text
84,2,24

```