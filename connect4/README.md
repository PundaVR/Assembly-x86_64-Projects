# Connect 4 in Assembly x86_64

- div (RAX holds quoitent - RDX holds remainder)

- jnz <label> - always checks for EAX == 0

## STACK ALLOCATIONS
- rbp-1 = CompareTile return
- rbp-2 = GetTile arrBoard byte pointer  

## Functions:
> ARGS: RDI, RSI, RDX
> RETURN: RAX

- Print (RDI string)
- 