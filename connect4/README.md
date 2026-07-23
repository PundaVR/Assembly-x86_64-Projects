# Connect 4 in Assembly x86_64

- div (RAX holds quoitent - RDX holds remainder)

- jnz <label> - always checks for EAX == 0

## STACK ALLOCATIONS
- rbp-1 = CompareTile return 
- rbp-2 = GetTile args1 (RDI)
- rbp-3 = GetTile args2 (RSI)
- rbp-4 = GetTile number of characters per row
- rbp-5 = GetTile number of rows
- rbp-6 = GetTile tiles per row

## Functions:
> ARGS: RDI, RSI, RDX
> RETURN: RAX

- Print (RDI string)
- GetTile
- CompareTile