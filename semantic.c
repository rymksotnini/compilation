#include "semantic.h"

bool error(char* info)
{
	printf("The room is not enough for %s!\n", info);
	return false;
}

int hashPJW(char* s)	//get the index of the string in the hash table of symbol list
{
	char* p = s;
	u_int h = 0, g;
	for (; *p!= 0; p++)
	{
		h = (h << 4) + (*p);
		if (g = h & 0xf0000000)
		{
			h = h ^ (g >> 24);
			h = h ^ g;
		}
	}
	return h % PRIME;
}

symbolN** initSymbolList()	//to let the symbol list initial
{
	int i;
	symbolN** symbolList = NULL;
	symbolList = (symbolN**)malloc(SYMBOL_LIST_LENGTH*sizeof(symbolN*));
	if (symbolList == NULL)
		return NULL;
	for (i = 0; i < SYMBOL_LIST_LENGTH; i++)
		symbolList[i] = NULL;
	return symbolList;
}

symbolN* getSymbolN(char* s,symbolN** symbolList) //get pointer of the token in the symbol list
{
	int index = hashPJW(s);
	symbolN* tmp = symbolList[index];
	while (tmp)
	{
		if (strcmp(s, tmp->name) == 0)
			return tmp;
		tmp = tmp->next;
	}
	return tmp;
}

bool insertIntoSymbolList(char* name, symbolN** symbolList)		//insert the identifier into the symbol list with the name of identifier
{
	int index = hashPJW(name);
	int stringLen = strlen(name)+1;
	symbolN* tmp;
	if (getSymbolN(name,symbolList) != NULL)		//return while there is it
		return false;
	if (symbolList[index] == NULL)
	{
		symbolList[index] = (symbolN*)malloc(sizeof(symbolN));
		if (symbolList[index] == NULL)
			return error("symbolList[index]");
		tmp = symbolList[index];
	}
	else
	{
		tmp = symbolList[index];
		while (tmp->next)
			tmp = tmp->next;
		tmp->next = (symbolN*)malloc(sizeof(symbolN));	//malloc the room for name of the identifire
		if (tmp->next == NULL)
			return error("tmp->next");
		tmp = tmp->next;
	}
	tmp->name = (char*)malloc(stringLen*sizeof(char));
	if (tmp->name == NULL)
		return error("tmp->name");
	strcpy(tmp->name, name);
	tmp->next = NULL;
	tmp->subList = NULL;
	return true;
}

symbolN** insertIntoSymbolListWithSublist(char* name, enum TypeSymbol typeS, symbolN** symbolList)		//insert the identifier into the symbol list with the name of identifier
{
	int index = hashPJW(name);
	int stringLen = strlen(name)+1;
	symbolN* tmp;
	if (getSymbolN(name,symbolList) != NULL)		//return while there is it
		return NULL;
	if (symbolList[index] == NULL)
	{
		symbolList[index] = (symbolN*)malloc(sizeof(symbolN));
		if (symbolList[index] == NULL)
			return NULL;
		tmp = symbolList[index];
	}
	else
	{
		tmp = symbolList[index];
		while (tmp->next)
			tmp = tmp->next;
		tmp->next = (symbolN*)malloc(sizeof(symbolN));	//malloc the room for name of the identifire
		if (tmp->next == NULL)
			return NULL;
		tmp = tmp->next;
	}
	tmp->name = (char*)malloc(stringLen*sizeof(char));
	if (tmp->name == NULL)
		return NULL;
	strcpy(tmp->name, name);
	tmp->next = NULL;
	tmp->type=typeS;
	tmp->subList=initSymbolList();
	return tmp->subList;
}

bool insertIntoSymbolListWithSublist1(char* name, enum TypeSymbol typeS,symbolN** symbolList, symbolN** sublist)		//insert the identifier into the symbol list with the name of identifier
{   bool x = true;
	bool notExist = true;
	symbolN* tmp=getSymbolN(name,symbolList);
	if(!tmp){
		insertIntoSymbolList2(name,typeS,0,0,0,symbolList);
		tmp=getSymbolN(name,symbolList);
	}
	if(tmp->subList==NULL){
		tmp->subList = sublist;
	}
		
	else
	{
		int i;
		symbolN* tmp2;
		for (i = 0; i < SYMBOL_LIST_LENGTH; i++)
		{
			tmp2 = sublist[i];
			while (tmp2)
			{  
				x=insertIntoSymbolList2(tmp2->name,tmp2->type, tmp2->Test_Init, tmp2->Test_Use, tmp2->nbrArg,tmp->subList);
				if(x == true){
					tmp2 = tmp2->next;
				}
				else{
					notExist = false;
					return notExist;
				}
			}
		}
	}
	return notExist;
}

bool insertIntoSymbolList2(char* name, enum TypeSymbol typeS, int Test_Init, int Test_Use, int nbrArg, symbolN** symbolList)		//insert the identifier into the symbol list with name, typeB...
{
	int index = hashPJW(name);
	int stringLen = strlen(name)+1;
	symbolN* tmp = getSymbolN(name,symbolList);
	if (tmp != NULL)		//return while there is it, and change the content
	{   
		fprintf( stderr, "\n variable %s deja declaree ",tmp->name);
		return false;
	}
	if (symbolList[index] == NULL)
	{
		symbolList[index] = (symbolN*)malloc(sizeof(symbolN));
		if (symbolList[index] == NULL)
			return error("symbolList[index]");
		tmp = symbolList[index];
	}
	else
	{
		tmp = symbolList[index];
		while (tmp->next)
			tmp = tmp->next;
		tmp->next = (symbolN*)malloc(sizeof(symbolN));	//malloc the room for name of the identifire
		if (tmp->next == NULL)
			return error("tmp->next");
		tmp = tmp->next;
	}
	tmp->name = (char*)malloc(stringLen*sizeof(char));
	if (tmp->name == NULL)
		return error("tmp->name");
	strcpy(tmp->name, name);
	tmp->Test_Init = Test_Init;
	tmp->Test_Use = Test_Use;
	tmp->type = typeS;
	tmp->nbrArg = nbrArg;
	tmp->subList = NULL;
	tmp->next = NULL;
	return true;
}


void showSymbolSubList( symbolN** symbolList)
{
	int i;
	symbolN* tmp;
	for (i = 0; i < SYMBOL_LIST_LENGTH; i++)
	{
		tmp = symbolList[i];
		while (tmp)
		{
			printf("%s\n", tmp->name);
			char* type = getTypeName(tmp->type);
			printf("type: %s\n", type);
			if(type == "function" ||  type == "procedure")
				printf("nbrArg: %d\n", tmp->nbrArg);
			if(tmp->subList!=NULL){
				printf("\n____sublist______\n");
				showSymbolList(tmp->subList);
				printf("\n_________________\n");
			}
			tmp = tmp->next;

		}
	}
	return;
}

void delSymbolList( symbolN** symbolList)	//to free the room gotten from system
{
	printf("Free the symbol table!\n");
	symbolN* levelOne;
	symbolN* levelOneN;
	int i;
	for (i = 0; i < SYMBOL_LIST_LENGTH; i++)
	{
		levelOne = symbolList[i];
		while (levelOne)
		{
			levelOneN = levelOne;
			free(levelOne->name);	//free the room for the name
            levelOne ->subList = NULL;
			levelOne = levelOne->next;
			free(levelOneN);
		}
	}
	free(symbolList);	//free the room for the symbol list
}

void affiche(char* name){
    printf("the ID name %s!\n", name);
}

char* getTypeName(enum TypeSymbol type) 
{
   switch (type) 
   {
      case variable: return "variable";
      case function: return "function";
	  case procedure: return "procedure";
   }
}
void showSymbolList( symbolN** symbolList)
{
	int i;
	symbolN* tmp;
	printf("\n_____________________The symbol list is:__________________________\n");
	for (i = 0; i < SYMBOL_LIST_LENGTH; i++)
	{
		tmp = symbolList[i];
		while (tmp)
		{
			printf("%s\n", tmp->name);
			char* type = getTypeName(tmp->type);
			printf("type: %s\n", type);
			if(type == "function" ||  type == "procedure")
				printf("nbrArg: %d\n", tmp->nbrArg);
			if(tmp->subList!=NULL){
				printf("\n____sublist______\n");
				showSymbolSubList(tmp->subList);
				printf("\n_________________\n");
			}
			tmp = tmp->next;

		}
	}
	printf("\n____________________________________________________________________\n");
	return;
}


void updateNbrArg(char* name, int nbr,symbolN** symbolList){
	symbolN* node = getSymbolN(name,symbolList);
	node->nbrArg = nbr; 
}

symbolN** concatenateTwoLists(symbolN** symbolList1,symbolN** symbolList2){
	int i;
	bool x=true;
	symbolN* tmp2;
	for (i = 0; i < SYMBOL_LIST_LENGTH; i++)
	{
		tmp2 = symbolList2[i];
		while (tmp2)
		{
            x=insertIntoSymbolList2(tmp2->name,tmp2->type, tmp2->Test_Init, tmp2->Test_Use, tmp2->nbrArg,symbolList1);
			if(x==true){
				tmp2 = tmp2->next;
			}
			if(x==false){
				return NULL;
			}
		}
	}
	return symbolList1;
}