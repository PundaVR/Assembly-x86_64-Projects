# Connect 4 in Assembly x86_64

- div (RAX holds quoitent - RDX holds remainder)

- jnz <label> - always checks for EAX == 0

## STACK ALLOCATIONS
- rbp-128 = CustomPrintMessage (32 bytes max)
- rbp-96 = something idk
- rbp-64 = GetTile args1 (RDI)
- rbp-56 = GetTile args2 (RSI)
- rbp-48 = InitBoard number of characters per row
- rbp-40 = InitBoard number of rows in board
- rbp 32 = SetTile: Character
XX- rbp-5 = GetTile number of rows
XX- rbp-6 = GetTile tiles per row
- rbp-1 = CompareTile return 

## Functions:
> ARGS: RDI, RSI, RDX
> RETURN: RAX

- Print (RDI string)
- GetTile
- CompareTile