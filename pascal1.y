%{
	

#include <stdio.h>	
#include "semantic.c"


void yyerror(char*);	
int yylex(void);
extern int line_no;
char *t;
symbolN **global_node;
symbolN **local_node;
%}

%union {
    char *a;
    double d;
    int fn;
	bool b;
	struct symbolN *node;
	
};

%type<a> PROGRAM SEMICOLOM DOT programmes liste_identificateurs COLON type declaration_corps
%type<node> ID

%token ID
%token NB
%token OPAFFECT
%token OPMUL
%token OPREL
%token SEMICOLOM
%token BEGIN_TOKEN
%token DO
%token ELSE
%token END
%token FUNCTION
%token IF
%token NOT
%token PROCEDURE
%token PROGRAM
%token THEN
%token VAR
%token WHILE
%token INT
%token OF
%token LB
%token RB
%token READ
%token WRITE
%token ADDOP
%token MULOP
%token ARRAY
%token LP
%token RP
%token NUMBER
%token OP_ASSIGN
%token OPERL
%token COLON
%token COMMA
%token DOT
%token DOTDOT
%token CHAINE

%error-verbose
%start programmes

%%
                                                           
programmes:  
	PROGRAM 
	ID 
	SEMICOLOM
	liste_declarations 
	declaration_methodes
	instruction_composee
	DOT			           
	|PROGRAM 
	ID 
	SEMICOLOM
	declaration_methodes
	instruction_composee
	DOT			            
	|PROGRAM 
	ID 
	SEMICOLOM
	liste_declarations 
	instruction_composee
	DOT			            
	|PROGRAM 
	 ID 
	 SEMICOLOM
	 instruction_composee
	 DOT					 { $$=$2; affiche($$); }
	|PROGRAM ID error                  {yyerror (" point virgule attendu "); YYABORT}
    |error ID SEMICOLOM            {yyerror (" program attendu "); YYABORT}
	|PROGRAM error SEMICOLOM       {yyerror (" nom du programme invalide"); YYABORT} 
;                             
liste_declarations:
	declaration
	liste_declarations
	| declaration 
;
declaration:
	VAR
	declaration_corps
	SEMICOLOM
;
declaration_corps:
	liste_identificateurs COLON type {t = $3; affiche($$);}
	| liste_identificateurs COLON error { yyerror("type manquant");YYABORT }
;
liste_identificateurs:
	ID COMMA liste_identificateurs {$$=$1;insertIntoSymbolList($$);} |
	ID {$$=$1; affiche($$);insertIntoSymbolList($$)}
	|ID error liste_identificateurs { yyerror("virgule manquant");YYABORT }
;
type:
	standard_type | ARRAY LB NUMBER DOTDOT NUMBER RB OF standard_type
;
standard_type:
	INT
;
declaration_methodes:
	declaration_methode 
	SEMICOLOM 
	declaration_methodes |
	declaration_methode SEMICOLOM
;
declaration_methode:
	entete_methode 
	liste_declarations
	instruction_composee |
	entete_methode 
	instruction_composee
;
entete_methode:
	PROCEDURE
	ID
	arguments 
	SEMICOLOM|
	PROCEDURE
	ID 
	SEMICOLOM|
	PROCEDURE
	ID 
	LP RP
	SEMICOLOM|
	FUNCTION
	ID
	arguments 
	COLON
	INT
	SEMICOLOM|
	FUNCTION
	ID 
	COLON
	INT
	SEMICOLOM|
	FUNCTION
	ID 
	LP RP
	COLON
	INT
	SEMICOLOM
;
arguments:
	LP liste_parametres RP
;
liste_parametres:
	declaration_corps 
	SEMICOLOM 
	liste_parametres  |
	declaration_corps
;
instruction_composee:
	BEGIN_TOKEN
	liste_instructions
	END |
	BEGIN_TOKEN
	END
;
liste_instructions:
	instruction SEMICOLOM liste_instructions |
	instruction SEMICOLOM|
	instruction error liste_instructions {yyerror (" point virgule attendu");YYABORT }
;
instruction:
	lvalue OP_ASSIGN expression_complexe |
	appel_methode |
	instruction_composee |
	IF expression_complexe THEN instruction ELSE instruction |
	WHILE expression_complexe DO instruction |
	WRITE LP liste_expressions RP |
	WRITE LP RP|
	WRITE LP CHAINE RP|
	READ LP liste_identificateurs RP| READ
;
lvalue:
	ID
	LB 
	expression 
	RB |
	ID
;
appel_methode:
	ID
	LP
	liste_expressions
	RP |
	ID
	LP
	RP
;
liste_expressions:
	expression_complexe COMMA liste_expressions |
	expression_complexe
;
expression_complexe:
	expression OPERL expression_complexe |
	expression
;
expression:
	facteur ADDOP facteur |
	facteur MULOP facteur |
	facteur
;
facteur:
	ID LB expression RB |
	NUMBER |
	LP expression_complexe RP |
	NOT LP expression_complexe RP |
	ID LP expression_complexe RP |
	ID
;
%% 

void yyerror(char *s) {
	extern int yylineno;
	fprintf(stderr,"Erreur (ligne n %d): %s\n",yylineno, s);
}

int main(int argc, char *argv[]) {
	global_node=initSymbolList();
	yyparse();
	yylex();
	showSymbolList(global_node);
	return 0;
}
  
                   





