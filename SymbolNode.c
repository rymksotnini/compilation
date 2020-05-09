#include "semantic.h" 

Symbol::Num() : num(0) { }
Num::Num(int n): num(n) {}
int Num::getNum()
{
 return num;
}