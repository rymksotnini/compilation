class SymbolNode
{

public:
    char* name;				
	TypeSymbol type;		
	int Test_Init;			
	int Test_Use;				
	int nbrArg;	
    SymbolNode* next;
	SymbolNode* subList;

    SymbolNode(/* args */);

    void add(SymbolNode symbolNode);
    void updateName(char* name);
    void updateType(TypeSymbol type);
    void updateTestInit(int Test_Init);
    void updateTestUse(int Test_Use);
    void updatenbrArg(int nbrArg);
    void updateNext(SymbolNode* next);
    void updateSubList(SymbolNode* sublist);
    void deleteNode();
};
