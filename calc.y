%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

//Abriol, Keanu Christopher F
//2021-04256
//CS 155 HDE FVW
// Mar 27, 2026

void yyerror(const char *msg);
int yylex(void);

int depth = 0; // Global variable to track the depth of the parse tree

void indent(int d) {
    for (int i = 0; i < d; i++) {
        printf("  "); // Indent with two spaces per level
    }
}



/* Define a structure for the parse tree nodes */
struct node {
    char label[26];
    struct node* left;
    struct node* middle;
    struct node* right;
};

typedef struct node Node;

/* Return type is a node pointer */
Node *makeNode(const char *label, Node *left_node, Node *middle_node, Node *right_node) {
    // Allocate memory for a new node
    Node *newNode = malloc(sizeof(Node));

    // Copy the label into the node's label field
    strncpy(newNode->label, label, 25);
    newNode->label[25] = '\0'; // Ensure null-termination

    // set the pointers of newly created node to the provided child nodes
    newNode->left = left_node;
    newNode->middle = middle_node;
    newNode->right = right_node;


    return newNode;
}

void print_tree(Node *root, int d) {
    if (root == NULL) {
        return;
    }

    indent(d);
    printf("%s\n", root->label);

    print_tree(root->left, d + 1);
    print_tree(root->middle, d + 1);
    print_tree(root->right, d + 1);
}
%}

%code requires {
    typedef struct node Node;
}


%union {
    int ival;
    double fval;
    Node* node;
}

%token <ival> NUM
%token <fval> FNUM
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN EXPO

%left PLUS MINUS
%left TIMES DIVIDE
%right UMINUS
%right EXPO                         

%type <node> expr term factor program


%%


program:
    expr
    {
        print_tree($1, 0);
    }
    ;

expr:

    expr PLUS term { //$$ = $1 + $3; 
    $$=makeNode("expr", $1, makeNode("+", NULL, NULL, NULL), $3); 
    }
    
    | expr MINUS term { //$$ = $1 - $3; 
    $$=makeNode("expr", $1, makeNode("-", NULL, NULL, NULL), $3); 
    }

    | term { //$$ = $1; 
    $$=makeNode("expr", $1, NULL, NULL); 
    }

    | expr EXPO expr { //$$ = pow($1, $3);
    $$=makeNode("expr", $1, makeNode("**", NULL, NULL, NULL), $3); 
    }
    ;

term:
    term TIMES factor { //$$ = $1 * $3;
        $$=makeNode("term", $1, makeNode("*", NULL, NULL, NULL), $3); // Create a node with the operator as label
     }
    | term DIVIDE factor { //$$ = $1 / $3;
        $$=makeNode("term", $1, makeNode("/", NULL, NULL, NULL), $3); 
     }
    | factor { //$$ = $1;
        $$ = makeNode("term", $1, NULL, NULL); 
     }
    ;

factor:
    NUM { 
        char buffer[26];
        snprintf(buffer, sizeof(buffer), "%d", $1); // Convert integer to string 
        $$ = makeNode("factor", makeNode(buffer, NULL, NULL, NULL), NULL, NULL); 
                
    }
    | FNUM { 
        char buffer[26];
        snprintf(buffer, sizeof(buffer), "%f", $1); // Convert float to string 
        $$ = makeNode("factor", makeNode(buffer, NULL, NULL, NULL), NULL, NULL); 
    }
    | LPAREN expr RPAREN { 
        $$ = makeNode("factor", makeNode("(", NULL, NULL, NULL), $2, makeNode(")", NULL, NULL, NULL)); 
    }
    | MINUS factor %prec UMINUS { 
         $$ = makeNode("factor", makeNode("-", NULL, NULL, NULL), $2, NULL); 
        
        }
    ;
%%

void yyerror(const char *msg) {
fprintf(stderr, "Parse error: %s\n", msg);
}


int main(void)
{
return yyparse();
}