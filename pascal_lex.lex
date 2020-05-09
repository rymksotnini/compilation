%{

#include "pascal.tab.h"
#define YYSTYPE char *
int line_no = 1;
%}
%option yylineno

delim     [ \t]
bl        {delim}+
chiffre   [0-9]
lettre    [a-zA-Z]
identificateur        {lettre}({lettre}|{chiffre})*
nb        ("-")?{chiffre}+("."{chiffre}+)?(("E"|"e")"-"?{chiffre}+)?
iderrone  {chiffre}({lettre}|{chiffre})*
ouvrante  (\()
fermante  (\))
chaine			\'[^\']*\'
literal_entier {chiffre}+
crochet_ouvrant "["
crochet_fermant "]"
mulop \*|\/|[dD][iI][vV]|[mM][oO][dD]|[aA][nN][dD]
addop \+|-|[oO][rR]
end_command ";"
ident_sep ","
interval_separator ".."
type_assignement ":" 
accolade_ouvrante "{"

%%

{bl}                                                                                 /* pas d'actions */
"\n" 			                                                                 {++line_no;printf("\n");}
[pP][rR][oO][gG][rR][aA][mM]                                                         {printf("PROGRAM "); return PROGRAM;}                  
[bB][eE][gG][iI][nN]                                                                 {printf("BEGIN "); return BEGIN_TOKEN;}
[eE][nN][dD]                                                                         {printf("END ");  return END; }
[iI][fF]                                                                             {printf("IF "); return  IF;}
[nN][oO][tT]                                                                         {printf("NOT "); return  NOT;}
[eE][lL][sS][eE]                                                                     {printf("ELSE ");return ELSE;} 			
[wW][hH][iI][lL][eE]                                                                 {printf("WHILE ");return WHILE;}
[pP][rR][oO][cC][eE][dD][uU][rR][eE]                                                 {printf("PROCEDURE "); return PROCEDURE;}
{end_command}                                                                        {printf("SEMICOLOM ");  return SEMICOLOM;}
[oO][fF] 	 								                                   {printf("OF "); return  OF;}
{crochet_ouvrant}	 						                                   {printf("crochet_ouvrant ");  return LB;}
{crochet_fermant}	 						                                   {printf("crochet_fermant ");  return RB;}
[dD][oO]                                                                             {printf("DO "); return DO;}
[fF][uU][nN][cC][tT][iI][oO][nN]                                                     {printf("FUNCTION "); return FUNCTION;}
[iI][nN][tT][eE][Gg][Ee][Rr]                                                                      {printf("INT "); yylval = strdup(yytext); return INT;}
[Rr][Ee][aA][dD]|[Rr][Ee][aA][dD][Ll][Nn]                                                                     {printf("READ "); return READ;}
[wW][Rr][iI][tT][eE]|[wW][Rr][iI][tT][eE][Ll][Nn]                                                            {printf("WRITE "); return WRITE;}
[tT][hH][eE][nN]                                                                     {printf("THEN ");return THEN;}
{addop}                                                                              {printf("ADD OPERATOR "); return ADDOP;}
{mulop}										                                 {printf("MUL OPERATOR "); return MULOP;}
[aA][rR][rR][aA][Yy]							                              {printf("ARRAY "); yylval = strdup(yytext); return ARRAY;}
[vV][aA][rR]                                                                         {printf("VAR ");return VAR;}
{ouvrante}                                                                           {printf(" parenthese_ouvrante "); return LP;}
{fermante}                                                                           {printf(" parenthese_fermante "); return RP;}
{identificateur}                                                                     {printf("ID "); yylval = strdup(yytext);  return ID;}
{nb}                                                                                 {printf("NUMBER "); return NUMBER;}
":="                                                                                 {printf("ASSIGN ");return OP_ASSIGN;}
=|<>|<|>|<=|>=                                                                      {printf("OPREL "); return OPERL; }
{type_assignement}                                                                   {printf("COLON "); return COLON;}
{ident_sep}                                                                          {printf("COMMA "); return COMMA;}
"."                                                                                  {printf("point ");return DOT; }
{interval_separator}                                                                 {printf("deux points ");return DOTDOT;}
{chaine} 									                                   {printf("CHAINE ");return CHAINE;}
" "                                                                                  {}
{iderrone}                                                                           {fprintf(stderr,"illegal identifier \'%s\' on line :%d\n",yytext,yylineno);}
"/*" {
    register int c;
    while ((c = input()))
    {
        if (c=='*')
        {
            if ((c = input()) == '/')
               { 
                printf("COMMENT_BLOCK");
                break;
               }
            else
                unput (c);
        }
        else if (c == '\n')
            yylineno++;
        else if(c == EOF){
             fprintf (stderr, "comment not closed at line %d\n",yylineno);
             exit(0);
        }
    }
}

%%

yywrap()
{
	return(1);
}
