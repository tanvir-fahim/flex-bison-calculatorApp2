%option noyywrap yylineno nounput noinput
%{
#include "cal.tab.h"
#include <string.h>
#include <stdlib.h>
%}

DIGIT   [0-9]
ID      [A-Za-z_][A-Za-z0-9_]*
NUMBER  ({DIGIT}+("."{DIGIT}*)?|("."{DIGIT}+))([eE][+-]?{DIGIT}+)?

%%

[ \t\r]+        ;
\n              { return '\n'; }

"=="            { return EQ; }
"!="            { return NEQ; }
"%%"            { return PERCENT; }

"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"^"             { return '^'; }

"("             { return '('; }
")"             { return ')'; }

"="             { return '='; }
"%"             { return '%'; }
"!"             { return '!'; }

","             { return ','; }

{NUMBER}        { yylval.d = atof(yytext); return NUMBER; }
{ID}            { yylval.s = strdup(yytext); return IDENT; }

.               { return yytext[0]; }

%%