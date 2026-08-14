%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void yyerror(const char *s);
int yylex(void);
extern int yylineno;

typedef struct Var {
    char *name;
    double val;
    struct Var *next;
} Var;

static Var *vars = NULL;

/* Convert degree to radian */
double deg(double x)
{
    return x * M_PI / 180.0;
}

/* Remove tiny floating-point errors */
double clean(double x)
{
    if (fabs(x) < 1e-12)
        return 0.0;

    return x;
}

double get_var(const char *name)
{
    for (Var *v = vars; v; v = v->next)
    {
        if (strcmp(v->name, name) == 0)
            return v->val;
    }

    if (strcmp(name, "pi") == 0)
        return M_PI;

    if (strcmp(name, "e") == 0)
        return M_E;

    yyerror("Undefined variable");
    return 0.0;
}

void set_var(const char *name, double val)
{
    for (Var *v = vars; v; v = v->next)
    {
        if (strcmp(v->name, name) == 0)
        {
            v->val = val;
            return;
        }
    }

    Var *n = malloc(sizeof(Var));

    n->name = strdup(name);
    n->val = val;
    n->next = vars;

    vars = n;
}

double factorial(double x)
{
    if (x < 0)
    {
        yyerror("Factorial of negative number");
        return 0;
    }

    double n = floor(x + 0.5);

    if (fabs(x - n) > 1e-9)
    {
        yyerror("Factorial requires an integer");
        return 0;
    }

    double result = 1;

    for (int i = 1; i <= (int)n; i++)
        result *= i;

    return result;
}
%}

%union
{
    double d;
    char *s;
}

%token <d> NUMBER
%token <s> IDENT

%token EQ NEQ
%token PERCENT

/* Precedence rules: Ordered from lowest to highest */
%left EQ NEQ
%left '+' '-'
%left '*' '/' '%'
%right '^'
%nonassoc '!' PERCENT
%right UMINUS UPLUS

%type <d> expr primary arg_list

%%

input:
      /* empty */
    | input line
    ;

line:
      '\n'

    | expr '\n'
      {
          printf("%.12g\n", $1);
      }

    | IDENT '=' expr '\n'
      {
          set_var($1, $3);
          printf("%.12g\n", $3);
          free($1);
      }
    ;

expr:
      expr '+' expr
      {
          $$ = $1 + $3;
      }

    | expr '-' expr
      {
          $$ = $1 - $3;
      }

    | expr '*' expr
      {
          $$ = $1 * $3;
      }

    | expr '/' expr
      {
          if ($3 == 0)
          {
              yyerror("Division by zero");
              $$ = 0;
          }
          else
          {
              $$ = $1 / $3;
          }
      }

    | expr '%' expr
      {
          if ($3 == 0)
          {
              yyerror("Modulo by zero");
              $$ = 0;
          }
          else
          {
              $$ = fmod($1, $3);
          }
      }

    | expr '^' expr
      {
          $$ = pow($1, $3);
      }

    | expr EQ expr
      {
          $$ = ($1 == $3) ? 1.0 : 0.0;
      }

    | expr NEQ expr
      {
          $$ = ($1 != $3) ? 1.0 : 0.0;
      }

    | expr '!'
      {
          $$ = factorial($1);
      }

    | expr PERCENT
      {
          $$ = $1 / 100.0;
      }

    | '-' expr %prec UMINUS
      {
          $$ = -$2;
      }

    | '+' expr %prec UPLUS
      {
          $$ = $2;
      }

    | primary
      {
          $$ = $1;
      }
    ;

primary:
      NUMBER
      {
          $$ = $1;
      }

    | IDENT '(' arg_list ')'
      {
          if (strcmp($1, "sin") == 0)
              $$ = clean(sin(deg($3)));

          else if (strcmp($1, "cos") == 0)
              $$ = clean(cos(deg($3)));

          else if (strcmp($1, "tan") == 0)
              $$ = clean(tan(deg($3)));

          else if (strcmp($1, "cot") == 0)
              $$ = clean(1.0 / tan(deg($3)));

          else if (strcmp($1, "sec") == 0)
              $$ = clean(1.0 / cos(deg($3)));

          else if (strcmp($1, "cosec") == 0)
              $$ = clean(1.0 / sin(deg($3)));

          else if (strcmp($1, "asin") == 0)
              $$ = clean(asin($3) * 180.0 / M_PI);

          else if (strcmp($1, "acos") == 0)
              $$ = clean(acos($3) * 180.0 / M_PI);

          else if (strcmp($1, "atan") == 0)
              $$ = clean(atan($3) * 180.0 / M_PI);

          else if (strcmp($1, "sqrt") == 0)
              $$ = sqrt($3);

          else if (strcmp($1, "exp") == 0)
              $$ = exp($3);

          else if (strcmp($1, "ln") == 0)
              $$ = log($3);

          else if (strcmp($1, "log") == 0)
              $$ = log10($3);

          else
          {
              yyerror("Unknown function");
              $$ = 0;
          }

          free($1);
      }

    | IDENT
      {
          $$ = get_var($1);
          free($1);
      }

    | '(' expr ')'
      {
          $$ = $2;
      }
    ;

arg_list:
      expr
      {
          $$ = $1;
      }
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "Error: %s (line %d)\n", s, yylineno);
}

int main(void)
{
    yyparse();
    return 0;
}