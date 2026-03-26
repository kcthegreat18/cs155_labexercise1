%{
#include <stdio.h>
%}

%%
[0-9]+    { printf("NUMBER: %s\n", yytext); }
[a-zA-Z]+ { printf("WORD: %s\n", yytext); }
.         { /* ignore */ }
%%

int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}