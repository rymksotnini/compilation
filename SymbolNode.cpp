#include "SymbolNode.h" 

SymbolNode::SymbolNode()  {
 }

SymbolNode::SymbolNode(char* name,TypeSymbol type,int Test_Init,int Test_Use,int nbrArg) {
    SymbolNode.name = name;
    SymbolNode.type= type;
    SymbolNode.Test_Init = Test_Init;
    SymbolNode.Test_Use = Test_Use;
    SymbolNode.nbrArg = nbrArg;
    SymbolNode.next = NULL;
    SymbolNode.subList = NULL;
}

void SymbolNode::add(){
    
}