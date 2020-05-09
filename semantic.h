#pragma once
#if !defined SYMBOLMANAGER_H
#define SYMBOLMANAGER_H
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#define NAME_CONTAINER_LENGTH 10000	//the length of the container of name

#define N 256
#define BUFFER 2048
#define PRIME 211
#define EOS '\0'
#define SYMBOL_LIST_LENGTH 211	//the length of the hash(in symbol list)

typedef unsigned int u_int;

enum TypeSymbol { function , variable, procedure };


typedef struct symbolNode	//the symbol list
{
	char* name;				
	enum TypeSymbol type;		
	int Test_Init;					
	int Test_Use;	
	int nbrArg;	
	struct symbolNode* next;
	struct symbolNode** subList;
} symbolN;

symbolN** initSymbolList();
int hashPJW(char* s);	//get the index of the string in the hash table of symbol list
symbolN* getSymbolN(char* s,symbolN** symbolList);
bool insertIntoSymbolList(char* name, symbolN** symbolList);		
symbolN** insertIntoSymbolListWithSublist(char* name, enum TypeSymbol typeS, symbolN** symbolList);	
bool insertIntoSymbolList2(char* name, enum TypeSymbol typeS, int Test_Init, int Test_Use, int nbrArg, symbolN** symbolList);
void showSymbolList( symbolN** symbolList);
void showSymbolSubList ( symbolN** symbolList);
void delSymbolList( symbolN** symbolList);
void affiche(char* name);
char* getTypeName(enum TypeSymbol type);
void updateNbrArg(char* name, int nbr,symbolN** symbolList);
bool insertIntoSymbolListWithSublist1(char* name, enum TypeSymbol typeS, symbolN** symbolList, symbolN** sublist);
symbolN** concatenateTwoLists(symbolN** symbolList1,symbolN** symbolList2);
#endif