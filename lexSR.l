delim     [ \t\n]
ws        {delim}+
digit     [0-9]
letter    [A-Za-z]
int       {digit}+
float     {digit}+\.({digit}+)?(E[+-]?{digit}+)?
id        {letter}({letter}|{digit})*
paren 	  "("|")"
relop     "=="|"<"|">"|"<="|">="|"<>"

%{

#include <stdlib.h>
#include <math.h>
#include "y.tab.h"
void yyerror(char *);

%}

%%
{ws}        {}
"exit"      {return(exit_command);}

"+"	    {return(PLUS);}
"-"	    {return(MINUS);}

"*"	    {return(TIMES);}
"/"	    {return(DIVIDE);}

"^"	    {return(POWER);}


"cos"	    {return(COS);}
"sin"	    {return(SIN);}
"exp"	    {return(EXP);}
"sqrt"	    {return(SQRT);}
"tan"	    {return(TAN);}
"pi"        {yylval.fnum = atan(1.0)*4;return float_; }
"e"         {yylval.fnum = exp(1.0);return float_; }

{paren}     {return yytext[0];}

{id}        {yylval.str = *yytext; return variable;}
{float}     {yylval.fnum = atof(yytext); return float_;}
{int}       {yylval.inum = atoi(yytext); return int_;}


{relop}     {return yytext[0];}
"="         {return(EQUALS);}
";"         {return yytext[0];}
.           {ECHO; yyerror("unexpected character");}
%%

/*int main (int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
}*/

int yywrap (void) {return 1;}
