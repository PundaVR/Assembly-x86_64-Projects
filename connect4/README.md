# Connect 4 in Assembly x86_64

- div (RAX holds quoitent - RDX holds remainder)

- jnz <label> - always checks for EAX == 0

## STACK ALLOCATIONS
- rbp-64 = GetTile args1 (RDI)
- rbp-56 = GetTile args2 (RSI)
- rbp-48 = GetTile number of characters per row
- rbp 40 = SetTile: Character
XX- rbp-5 = GetTile number of rows
XX- rbp-6 = GetTile tiles per row
- rbp-1 = CompareTile return 

## Functions:
> ARGS: RDI, RSI, RDX
> RETURN: RAX

- Print (RDI string)
- GetTile
- CompareTile