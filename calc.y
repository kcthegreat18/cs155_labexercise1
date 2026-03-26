%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(const char *msg);
int yylex(void);
%}

%union {
    int ival;
    double fval;
}

%token <ival> NUM
%token <fval> FNUM
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN EXPO

%left PLUS MINUS
%left TIMES DIVIDE
%right UMINUS
%right EXPO                         

%type <fval> expr term factor


%%


program:
    expr { printf("Result: %f\n", $1); }
    ;

expr:

    expr PLUS term { $$ = $1 + $3; }
    | expr MINUS term { $$ = $1 - $3; }
    | term { $$ = $1; }
    | expr EXPO expr {$$ = pow($1, $3);}
    ;

term:
    term TIMES factor { $$ = $1 * $3; }
    | term DIVIDE factor { $$ = $1 / $3; }
    | factor { $$ = $1; }
    ;

factor:
    NUM { $$ = $1; }
    | FNUM { $$ = $1;}
    | LPAREN expr RPAREN { $$ = $2; }
    | MINUS factor %prec UMINUS { $$ = -$2; }
    ;
%%

void yyerror(const char *msg) {
fprintf(stderr, "Parse error: %s\n", msg);
}


int main(void)
{
return yyparse();
}