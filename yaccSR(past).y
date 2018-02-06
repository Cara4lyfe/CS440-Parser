%{
#include "global.h"
#include <stdio.h>   
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
  void yyerror (char *s);
  int yylex(void);
  float symbols[52];
  float symbolVal(char symbol);
  void updateSymbolVal(char symbol, float val);
%}

%start line
%token exit_command

%token  EQUALS
%token	PLUS	MINUS	TIMES	DIVIDE	POWER

%token variable
%token int_
%token float_

%left	PLUS	MINUS
%left	TIMES	DIVIDE
%left	NEG
%right	POWER

%%
line : f_assignment ';' {;}
     | f_expr ';' {printf("Printing %f\n", $1); }
     | i_assignment ';' {;}
     | i_expr ';' {printf("Printing %d\n", (int)$1); }
     | exit_command ';' {exit(EXIT_SUCCESS);}
     | line f_assignment ';' {;}
     | line f_expr ';' {printf("Printing %f\n", $2);}
     | line i_assignment ';' {;}
     | line i_expr ';' {printf("Printing %d\n", (int)$2);}
     | line exit_command ';' {exit(EXIT_SUCCESS);}
;

/*float operations*/
f_assignment : variable EQUALS f_expr { updateSymbolVal($1,$3); }
           | variable EQUALS f_assignment { updateSymbolVal($1,symbolVal($3)); }
;

f_expr : f_term          {$$ = $1;}
     | f_expr PLUS f_term {$$ = $1 + $3;}
     | f_expr MINUS f_term {$$ = $1 - $3;}
;

f_term : f_fun		{$$ = $1;}
     | f_term TIMES f_fun     {$$ = $1 * $3;}
     | f_term DIVIDE f_fun     {$$ = $1 / $3;}
     | f_term POWER f_fun   {$$ = pow($1,$3);}

;

f_fun : variable       {$$ = symbolVal($1);}
     | float_        {$$ = $1;}
     | '(' f_expr ')'   {$$ = $2;}
;

/*int operations*/

i_assignment : variable EQUALS i_expr { updateSymbolVal($1,$3); }
           | variable EQUALS i_assignment { updateSymbolVal($1,symbolVal($3)); }
;

i_expr : i_term          {$$ = (int)$1;}
     | i_expr PLUS i_term {$$ = (int)$1 + (int)$3;}
     | i_expr MINUS i_term {$$ = (int)$1 - (int)$3;}
;

i_term : i_fun		{$$ = (int)$1;}
     | i_term TIMES i_fun     {$$ = (int)$1 * (int)$3;}
     | i_term DIVIDE i_fun     {$$ = (int)$1 / (int)$3;}
     | i_term POWER i_fun   {$$ = (int)pow($1,$3);}

;

i_fun : /*variable       {$$ = symbolVal($1);}*/
     | int_          {$$ = (int)$1; printf("INSIDE i_fun %d\n",(int)$$);}
     | '(' i_expr ')'   {$$ = (int)$2;}
;




%%

int computeSymbolIndex(char token)
{
  int idx = -1;
  if(islower(token)) {
    idx = token - 'a' + 26;
  } else if(isupper(token)) {
    idx = token - 'A';
  }
  return idx;
}

float symbolVal(char symbol)
{
  int bucket = computeSymbolIndex(symbol);
  return symbols[bucket];
}

void updateSymbolVal(char symbol, float val)
{
  int bucket = computeSymbolIndex(symbol);
  symbols[bucket] = val;
}

int main (void) {
  int i;
  for(i=0; i<52; i++) {
    symbols[i] = 0;
  }

  return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}
