%{
#include <stdio.h>   
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
int yylex(void);
  void yyerror (char *s);
  float symbols[52];
  float symbolVal(char symbol);
  void updateSymbolVal(char symbol, float val);

%}

%start line

%union
{
	int inum;
	float fnum;	
	char str;   
}

%token exit_command
%token  EQUALS
%token	PLUS	MINUS	TIMES	DIVIDE	POWER
%token  <str> variable
%token <inum> int_
%token <fnum> float_

%left	<fnum> PLUS	MINUS
%left	<fnum> TIMES	DIVIDE
%left	<fnum> COS EXP SIN SQRT TAN
%right	<fnum> POWER

%type <fnum> line 
%type <fnum> f_assignment f_expr f_term 
%type <fnum> f_fun 
%type <inum> i_assignment i_expr i_term 
%type <inum> i_fun

%%
line : f_assignment ';'        {;}
     | f_expr ';'              {printf("Printing %f\n", $1); }
     | i_assignment ';'        {;}
     | i_expr ';'              {printf("Printing %d\n", $1); }
     | exit_command ';'        {exit(EXIT_SUCCESS);}
     | line f_assignment ';'   {;}
     | line f_expr ';'         {printf("Printing %f\n", $2);}
     | line i_assignment ';'   {;}
     | line i_expr ';'         {printf("Printing %d\n", $2);}
     | line exit_command ';'   {exit(EXIT_SUCCESS);}
;


f_assignment : variable EQUALS f_expr        { updateSymbolVal($1,$3); }
           | variable EQUALS f_assignment    { updateSymbolVal($1,symbolVal($3)); }
;

f_expr : f_term                {$$ = $1;}
     | f_expr PLUS f_term      {$$ = $1 + $3;}
     | f_expr MINUS f_term     {$$ = $1 - $3;}
	/*float into int*/
     | f_expr PLUS i_term      {$$ = $1 + $3;}
     | f_expr MINUS i_term     {$$ = $1 - $3;}
	/*float into int*/
     | i_expr PLUS f_term      {$$ = $1 + $3;}
     | i_expr MINUS f_term     {$$ = $1 - $3;}
/* Chandler added */
     | COS f_term	       {$$ = cos($2);}
     | SIN f_term	       {$$ = sin($2);}
     | EXP f_term	       {$$ = exp($2);}
     | SQRT f_term	       {$$ = sqrt($2);}
     | TAN f_term	       {$$ = tan($2);}
;

f_term : f_fun		       {$$ = $1;}
     | f_term TIMES f_fun      {$$ = $1 * $3;}
     | f_term DIVIDE f_fun     {$$ = $1 / $3;}
     | f_term POWER f_fun      {$$ = pow($1,$3);}
	/*float into int*/
     | f_term TIMES i_fun      {$$ = $1 * $3;}
     | f_term DIVIDE i_fun     {$$ = $1 / $3;}
     | f_term POWER i_fun      {$$ = pow($1,$3);}
	/*float into int*/
     | i_term TIMES f_fun      {$$ = $1 * $3;}
     | i_term DIVIDE f_fun     {$$ = $1 / $3;}
     | i_term POWER f_fun      {$$ = pow($1,$3);}

;

f_fun : float_                 {$$ = $1;}
    	| '(' f_expr ')'       {$$ = $2;}
	| variable             {$$ = symbolVal($1);}
;

/*ints*/

i_assignment : variable EQUALS i_expr         { updateSymbolVal($1,$3); }
           | variable EQUALS i_assignment     { updateSymbolVal($1,symbolVal($3)); }
;

i_expr : i_term                {$$ = $1;}
     | i_expr PLUS i_term      {$$ = $1 + $3;}
     | i_expr MINUS i_term     {$$ = $1 - $3;}
     | SQRT i_term	       {$$ = sqrt((float)$2);}
;

i_term : i_fun 		       {$$ = $1;}
     | i_term TIMES i_fun      {$$ = $1 * $3;}
     | i_term DIVIDE i_fun     {$$ = $1 / $3;}
     | i_term POWER i_fun      {$$ = pow($1,$3);}
;

i_fun : int_		       {$$ = $1;}
	| '(' i_expr ')'       {$$ = $2;};


%%

float computeSymbolIndex(char token)
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
