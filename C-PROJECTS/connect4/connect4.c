#include <stdio.h>
#include <stdlib.h>

struct Board
{
    unsigned char *data;
    size_t size;
    int x;
    int y;
};

int GetBoardMemSize(int x, int y)
{
    return (x * y * 3) + (y - 1);
    /* amount of char = 29
    [ ][ ][ ]\n 10
    [ ][ ][ ]\n 10
    [ ][ ][ ] 9
    */
}

void InitBoard(struct Board board){
    printf("print");

    int totalCells = 0;
    for (unsigned char i = 0; i < board.y; i++)
    {
        int counter = 0;
        for (int x = 0; x <= board.x * 3; x++)
        {
            if (counter == 0)
            {
                board.data[totalCells] = '[';
            }
            else if (counter == 1)
            {
                board.data[totalCells] = ' ';
            }
            else
                board.data[totalCells] = ']';

            if (x == (board.x * 3))
                board.data[totalCells] = '\n';

            printf("%d: %c\n", i, board.data[totalCells]);

            counter++;

            if (counter > 2)
                counter = 0;

            totalCells++; // -1 i guess since we never write i as its out of bounds?
        }
    }
    printf("\nActual size: %ld\nTotal size: %d\nPredicted size: %d", sizeof(board), totalCells, board.size);

}

unsigned char GetCell(struct Board board, int x, int y)
{
    int index = 1;
    x = x * 3;
    y = y * (board.x * 3) + y;
    index += x + y;

    return board.data[index];
}

int SetCell(struct Board board, int x, int y, unsigned char token)
{
    int index = 1;
    x = x * 3;
    y = y * (board.x * 3) + y;
    index += x + y;

    board.data[index] = token;
}

void PrintBoard(struct Board board)
{
    printf("\nPRINTING BOARD:\n");
    for (int i = 0; i < board.x; i++) printf(" %d ", i);
    printf("\n");


    int i = 0;
    for (;;)
    {
        printf("%c", board.data[i]);
        if (board.data[i] == 0)
            break;
        i++;
    }
}

int GetColumnGravity(struct Board board, int x){
    int foundEmpty = 0;
    int newY = 0;
    while (newY < board.y && foundEmpty == 0){
        unsigned char cell = GetCell(board, x, newY);
        printf("\nCheck cell: %c  -->  cell == %d", cell, (short)cell);
        if (cell != 32 || newY > board.y-1) foundEmpty = 1;
        else newY++;
    }
    
    printf("\nnewY = %d", newY);
    return newY-1;
}

int GetUserInputX(struct Board board){
    int xPos = 0;
    printf("\nEnter board size along HORIZONTAL (x): ");
    if (scanf("%d", &xPos) != 1)
    {
        printf("Invalid input!\n");
        return 1;
    }
    if (xPos >= board.x) return GetUserInputX(board);
    return xPos;
}

void WriteFinalBoardToFile(struct Board board) {
    FILE *f = fopen("output.txt", "wb");
    if (f == NULL) printf("\nshit\n");
    fwrite(board.data, board.size, 1, f);
    fclose(f);
}

int main(int argc, char **argv)
{
    int gameActive = 1;
    int boardX = 0;
    int boardY = 0;

    printf("\nEnter board size along HORIZONTAL (x): ");
    if (scanf("%d", &boardX) != 1)
    {
        printf("Invalid input!\n");
        return 1;
    }

    printf("Enter board size along VERTICAL (y): ");
    if (scanf("%d", &boardY) != 1)
    {
        printf("Invalid input!\n");
        return 1;
    }

    int boardSize = GetBoardMemSize(boardX, boardY);

    struct Board board;
    board.data = calloc(boardSize, sizeof(unsigned char)); // [ ][ ][ ]\n
    board.size = boardSize;
    board.x = boardX;
    board.y = boardY;

    InitBoard(board);
    unsigned char player1Token = 'X';
    unsigned char player2Token = 'O';

    int maxTurns = 20; // after 20 turns end game
    int turnCount = 0;
    while (gameActive){
        unsigned char token = player2Token == token ? player1Token : player2Token;
        PrintBoard(board);
        int x = GetUserInputX(board);
        int y = GetColumnGravity(board, x);
        SetCell(board, x, y, token);

        turnCount++;
        gameActive = turnCount > maxTurns ? 0 : 1;
    }
    
    printf("\n\n=====================\nGAME OVER\n=====================\n\n");
    WriteFinalBoardToFile(board);

    free(board.data);
    return 0;
}