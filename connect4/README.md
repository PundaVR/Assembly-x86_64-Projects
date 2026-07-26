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

- rbp-8 = GetUserInput - amount of chars inputted (2 for x, 3 for xy)
- rbp-7 = CompareTile return 
- rbp-6 = Player1 Token i.e: 'X'
- rbp-5 = Player2 Token i.e: 'O'
- rbp-4 = Active User's Character Token i.e: 'X'
- rbp-3 = Last X user input
- rbp-2 = Last Y user input (effected by gravity)
- rbp-1 = Game Active = true

## Functions:
> ARGS: RDI, RSI, RDX
> RETURN: RAX

- Print (RDI string)
- GetTile
- CompareTile