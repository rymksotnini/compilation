%{
	

#include <stdio.h>	
#include "semantic.c"

void yyerror(char*);	
int yylex(void);
extern int line_no;
char *t;
symbolN **globalSymbolList;
symbolN **localSymbolList;
bool localScope;
int nbrArg;
int nbrParam;
extern int yylineno;
bool x;
%}

%union {
    char *a;
    double d;
    int fn;
	bool b;
	symbolN** nodeList;
	
};

%type<a> ID PROGRAM SEMICOLOM DOT programmes COLON type entete_methode 
%type<nodeList> liste_identificateurs arguments declaration_corps liste_parametres liste_declarations declaration 

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
	liste_declarations_global 
	declaration_methodes
	instruction_composee
	DOT			   { showSymbolList(globalSymbolList); }        
	|PROGRAM 
	ID 
	SEMICOLOM
	declaration_methodes
	instruction_composee 
	DOT			            { showSymbolList(globalSymbolList); }
	|PROGRAM 
	ID 
	SEMICOLOM
	liste_declarations_global
	instruction_composee
	DOT			        { showSymbolList(globalSymbolList); }    
	|PROGRAM 
	 ID 
	 SEMICOLOM
	 instruction_composee
	 DOT					 { showSymbolList(globalSymbolList); }
	|PROGRAM ID error                  {yyerror (" point virgule attendu "); YYABORT}
    |error ID SEMICOLOM            {yyerror (" program attendu "); YYABORT}
	|PROGRAM error SEMICOLOM       {yyerror (" nom du programme invalide"); YYABORT} 
;

liste_declarations_global:
	liste_declarations{
		globalSymbolList=concatenateTwoLists($1,globalSymbolList);
		nbrArg=0;
	}
;
liste_declarations:
	declaration
	liste_declarations{
		$$=concatenateTwoLists($1,$2);
	}
	| declaration {
		
		$$ = $1;

	}
;
declaration:
	VAR
	declaration_corps
	SEMICOLOM {
		$$=$2;
	} 
;
declaration_corps:
	liste_identificateurs COLON type {
		$$=$1;

	}
	| liste_identificateurs COLON error { yyerror("type manquant"); YYABORT }
;
liste_identificateurs:
	ID COMMA liste_identificateurs
	{ 
		$$=$3;
		x=insertIntoSymbolList2($1, variable, 0, 0, 0, $$);
		if(x==false)
		{
			yyerror("");
			YYABORT;
		}
		nbrArg = nbrArg + 1;
	} 
	|
	ID 
	{
		$$ = initSymbolList();
		x=insertIntoSymbolList2($1, variable, 0, 0, 0, $$);

		if(x==false)
		{
			yyerror("");
			YYABORT;
		}
		nbrArg = nbrArg + 1;
	}
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
	declaration_methodes {
	} |
	declaration_methode SEMICOLOM
	{
	}
;
liste_declarations_local:
	entete_methode
	liste_declarations{			
		symbolN* node=getSymbolN($1,globalSymbolList);
		x=insertIntoSymbolListWithSublist1($1,node->type,globalSymbolList,$2); 
		if(x==false)
		{
			yylineno=yylineno-1;
			yyerror("");
			YYABORT;
		}
	}
;
declaration_methode: 
	liste_declarations_local
	instruction_composee 
	{
		nbrArg=0
	}
	|
	entete_methode 
	instruction_composee
	{
		nbrArg=0
	}
	|
	entete_methode
	{
		nbrArg=0
	}
;
entete_methode:
	PROCEDURE
	ID
	arguments 
	SEMICOLOM {
		$$=$2;
		insertIntoSymbolListWithSublist1($2, procedure, globalSymbolList, $3);
		updateNbrArg($2,nbrArg,globalSymbolList);
	}
	|
	PROCEDURE
	ID 
	SEMICOLOM {
		insertIntoSymbolListWithSublist($2, procedure, globalSymbolList);
	}
	|
	PROCEDURE
	ID 
	LP RP
	SEMICOLOM {
		insertIntoSymbolListWithSublist($2, procedure, globalSymbolList); 
	}
	|
	FUNCTION
	ID
	arguments 
	COLON
	INT
	SEMICOLOM {
		$$=$2;
		insertIntoSymbolListWithSublist1($2, function, globalSymbolList, $3);
		updateNbrArg($2,nbrArg,globalSymbolList);
	}
	|
	FUNCTION
	ID 
	COLON
	INT
	SEMICOLOM {
		insertIntoSymbolListWithSublist($2, function, globalSymbolList); 
	}
	|
	FUNCTION
	ID 
	LP RP
	COLON
	INT
	SEMICOLOM {
		insertIntoSymbolListWithSublist($2, function, globalSymbolList); 
	}
;
arguments:
	LP liste_parametres RP 
	{
		$$=$2;
	}
;
liste_parametres:
	declaration_corps 
	SEMICOLOM 
	liste_parametres {
		$$=concatenateTwoLists($3,$1);
	} 
	|
	declaration_corps {
		$$=$1;

	}
;
instruction_composee:
	BEGIN_TOKEN
	liste_instructions
	END 
	{
		localSymbolList = NULL;
	}
	|
	BEGIN_TOKEN
	END
	{
		localSymbolList = NULL;
	}
	
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
	RP {
		symbolN* node = getSymbolN($1,globalSymbolList);
		if (node) {
			printf("\n nbr param: %d \n",nbrParam);
			printf("\n nbr arg: %d \n",node->nbrArg);
			if (nbrParam!=node->nbrArg){
				printf("\n Nombre d'arguments incorrectes \n");
				yyerror("");
				YYABORT;
			}
		}
		else {
			printf("\n methode %s non declaree \n",$1);
			yyerror("");
			YYABORT;
		}
		nbrParam = 0;
	} 
	|
	ID
	LP
	RP {
		symbolN* node = getSymbolN($1,globalSymbolList);
		if (node) {
			printf("\n nbr param: %d \n",nbrParam);
			printf("\n nbr arg: %d \n",node->nbrArg);
			if (nbrParam!=node->nbrArg){
				printf("\n Nombre d'arguments incorrectes \n");
				yyerror("");
				YYABORT;
			}
		}
		else {
			printf("\n methode %s non declaree \n",$1);
			yyerror("");
			YYABORT;
		}
		nbrParam = 0;
	} 
;
liste_expressions:
	expression_complexe COMMA liste_expressions {
		printf("nbr ++ %d",nbrParam);
		nbrParam = nbrParam+1;
	}
	|
	expression_complexe {
		printf("nbr ++ %d",nbrParam);
		nbrParam = nbrParam+1;
	}
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
	fprintf(stderr,"Erreur (ligne n %d) %s\n",yylineno, s);
}

int main(int argc, char *argv[]) {
	localScope = false;
	x=true;
	nbrArg=0;
	nbrParam = 0;
	globalSymbolList=initSymbolList();
	yyparse();
	yylex();
	return 0;
}