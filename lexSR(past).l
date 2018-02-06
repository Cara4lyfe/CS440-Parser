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
#include "global.h"
#include <stdlib.h>
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

{paren}     {return yytext[0];}

{id}        {yylval = *yytext; return variable;}
{float}     {yylval = atof(yytext); return float_;}
{int}       {yylval = atoi(yytext); return int_;}


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
