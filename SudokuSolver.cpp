#include <iostream>
using namespace std;

bool isSafe(int mat[][9],int i , int j , int num){
    for(int k = 0;k<9;k++){
        if(mat[k][j]==num||mat[i][k]==num){
            return false;
        }
    }
    int sx = (i/3)*3;
    int sy = (j/3)*3;
    for(int x = sx;x<sx+3;x++){
        for(int y = sy;y<sy+3;y++){
            if(mat[x][y]==num){
                return false;
            }
        }
    }
    return true;
}

bool solveSudoku(int mat[][9],int i , int j){
    if(i==9){ //base case
        for(int x = 0;x<i;x++){
            for(int y = 0;y<9;y++){
                cout<<mat[x][y]<<" ";
            }
            cout<<endl;
        }
        cout<<endl;
        return true;
    }
    //recursive case
    if(j==9){
        return solveSudoku(mat,i+1,0);
    }
    if(mat[i][j]!=0){
        return solveSudoku(mat,i,j+1);
    }
    for(int num=1;num<=9;num++){
        if(isSafe(mat,i,j,num)){
            mat[i][j]=num;
            bool subproblem = solveSudoku(mat,i,j+1);
            if(subproblem){
                return true;
            }
        }
    }
    //backtracking
    mat[i][j] = 0;
    return false;
}

int main()
{
    int mat[9][9]=
    {{5,3,0,0,7,0,0,0,0},
    {6,0,0,1,9,5,0,0,0},
    {0,9,8,0,0,0,0,6,0},
    {8,0,0,0,6,0,0,0,3},
    {4,0,0,8,0,3,0,0,1},
    {7,0,0,0,2,0,0,0,6},
    {0,6,0,0,0,0,2,8,0},
    {0,0,0,4,1,9,0,0,5},
    {0,0,0,0,8,0,0,7,9}};
     
    if(!solveSudoku(mat,0,0)){
        cout<<"NO SOLUTION POSSIBLE!"<<endl;
    } 
    return 0;
}
