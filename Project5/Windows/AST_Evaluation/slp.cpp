/*
* Programmer: Jeremy Saltz
* Class: CSCI 4160
* Program description:
* The program is an interpiter for a simple programming language.
* The program takes an abstract syntax string as input and then the 
* interpeter will then output what the program is doing.
*/

#include <algorithm>
#include "slp.h"


using namespace std;

//interpet a compound statement
void CompoundStm::interp( SymbolTable& symbols )
{

	// first statement
	stm1->interp(symbols);

	//second statement
	stm2->interp(symbols);
}


/* assign exp to the symbols table  */
void AssignStm::interp( SymbolTable& symbols )
{
	// id is the key to the exp in the symbols table
	symbols[id] = exp->interp(symbols);
}

// interpet expression and print the results for print stm
void PrintStm::interp( SymbolTable& symbols )
{
	//interpet and print
	exps->interp(symbols);
	cout << endl;// for formatting if there are multiple lines
}

// returns the variable from the symbol table
int IdExp::interp( SymbolTable& symbols )
{
	// return from symbol table
	return symbols[id];
}

// return the number value
int NumExp::interp( SymbolTable& symbols )
{
	// return num value
	return num;
}

// interpet a operator expression
int OpExp::interp( SymbolTable& symbols )
{
	// get left and right operands
	int leftVal = left->interp(symbols);  // Evaluate the left operand
	int rightVal = right->interp(symbols);  // Evaluate the right operand

	// checks for the type of operation
	switch (oper) {
	case PLUS:
		return leftVal + rightVal;
	case MINUS:
		return leftVal - rightVal;
	case TIMES:
		return leftVal * rightVal;
	case DIV:
		// Check for division by zero; return 0 as a simple fallback
		return rightVal != 0 ? leftVal / rightVal : 0;
	default:
		// Return 0 by default if the operation is unrecognized
		return 0;
	}
}

// executes statement before evaluating and returning the value
int EseqExp::interp( SymbolTable& symbols )
{
	// execute the statement
	stm->interp(symbols);

	// evaluate and return the expression
	return exp->interp(symbols);
}

// interpret a list of expressions and print the results
void PairExpList::interp( SymbolTable& symbols)
{
	//print the head and add a space for formatting
	cout << head->interp(symbols) << " ";

	//interpet the tail recursivly
	tail->interp(symbols);
}

// interpret the last or only expression in a list
void LastExpList::interp( SymbolTable& symbols)
{
	//print the lone expression
	cout << head->interp(symbols);
}