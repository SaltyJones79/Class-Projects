 /*
	Programmer: Jeremy Saltz
	Class: CSCI 4160
	Program Discription:
	This is a BISON syntax analyzer using a CFG for the COOL
	The program scans a COOL program for any syntax errors 
	and reports any errors while still moving on to scan the 
	program. If the the code doesn't have any syntax errors it
	just reports that is parsed succesfully. 
 */
%debug
%verbose
%locations

%code requires {
#include <iostream>
#include "ErrorMsg.h"
#include "StringTab.h"

int yylex(void); /* function prototype */
void yyerror(char *s);	//called by the parser whenever an eror occurs

}

%union {
	bool		boolean;	
	Symbol		symbol;	
}

%token <symbol>		STR_CONST TYPEID OBJECTID INT_CONST 
%token <boolean>	BOOL_CONST

%token CLASS ELSE FI IF IN 
%token INHERITS LET LOOP POOL THEN WHILE 
%token CASE ESAC OF DARROW NEW ISVOID 
%token ASSIGN NOT LE 

 /* Precedence declarations after adding the rest in with the right order. */
%left LET_STMT
%left LET
%right ASSIGN
%left NOT
%nonassoc LE '<' '='
%left '-' '+'
%left '*' '/'
%left ISVOID
%left '~'
%left '@'
%left '.'

/*
* The above only gives precedence levels of some operators.
* Please provide precedence levels of other operators : LE '<' '=', ISVOID '~' '@' '.'
*/

%start program

%%

/*
 * The following is CFG of COOL programming languages. Several simple rules in the following comments are given for demonstration purpose.
 * You can uncomment them and provide extra rules for the CFG. Please be noted that you uncomment without providing extra rules, BISON will
 * will report errors when compiling COOL.yy file since several non-terminals are not defined.
 * 
 
 * No rule action needed in this assignment 
 * If a recusive rule is needed, for example, define a list of something, always use 
 * right recursion like:
 * class_list : class class_list
 *
 */

 //This rule is introduced to avoid compilation error.
 //When you start working on the project, please delete this rule.
 


//A COOL program is viewed as a list of classes 
program	: class_list
        ;

//To handle a list of classes with error recovery
class_list 	: class			
        | error ';'             // error in the first class
		| class class_list 		// several classes
		| class_list error ';'  // error message 
		;

// If no parent is specified, the class inherits from the Object class. 
class : CLASS TYPEID '{' optional_feature_list '}' ';'
		| CLASS TYPEID INHERITS TYPEID '{' optional_feature_list '}' ';'
		| CLASS error // error recovery
		;

// Feature list may be empty, but no empty features in list. 

optional_feature_list:		//empty body for this rule
        | feature_list
		| error // error recovery
        ;

// feature lists and error handling
feature_list :	feature	';'
			 | error ';'
			 | feature error 
			 |	feature	';'	feature_list
			 | feature error feature_list
			 ;

// feature with error checking
feature	:	OBJECTID '(' optional_formal_list ')' ':' TYPEID '{' expr '}' 
		| OBJECTID ':' TYPEID optional_assign_expr
		| error ';'
		;

// optional assignment expressions with error hadling for initialization
optional_assign_expr : /* empty */
                     | ASSIGN expr
                     ;

// optional formal list with error handling for method parameters
optional_formal_list : /* empty body */
					| formal_list
					;

// formal list defition with error handling for formal parameters
formal_list : formal
			| formal ',' formal_list
			| formal error formal_list
			| error ',' formal_list
			;

// formal definition with error handling for single parameter
formal :	OBJECTID ':' TYPEID
		|	error ':' TYPEID
		|	OBJECTID error TYPEID
		|	OBJECTID ':' error
		;

// various expression definitions for COOL
expr :	OBJECTID ASSIGN expr
	 | expr '@' TYPEID '.' OBJECTID '(' optional_expr_list ')'
	 | expr '.' OBJECTID '(' optional_expr_list ')'
	 | OBJECTID '(' optional_expr_list ')'
	 | IF expr THEN expr ELSE expr FI
	 | WHILE expr LOOP expr POOL
	 | '{' expr_seq '}' 
	 | LET let_decl_seq IN expr
	 | CASE expr OF case_branches ESAC
	 | NEW TYPEID
	 | ISVOID expr
	 | expr '+' expr
	 | expr '-' expr
	 | expr '*' expr
	 | expr '/' expr
	 | '~' expr
	 | expr '<' expr
	 | expr LE expr
	 | expr '=' expr
	 | NOT expr
	 | '(' expr ')'
	 | OBJECTID
	 | INT_CONST
	 | STR_CONST
	 | BOOL_CONST
	 | error // error checking
	 ;

// Defines a LET declaration
let_decl : OBJECTID ':' TYPEID optional_assign_expr
		 | error
		 ;

// Defines a sequence of LET declarations
let_decl_seq :	let_decl
			 |	let_decl ',' let_decl_seq
			 | let_decl error let_decl_seq // Error between LET declarations
			 | error  let_decl_seq // Error before a LET declaration sequence
			 ;

// Optional list of expressions
optional_expr_list :	/* empty */
				   |	expr_list
				   ;

// Defines a list of expressions
expr_list :	expr
		  | expr error
		  | expr ',' expr_list
		  | expr error expr_list
		  | error expr_list // Error at the start of expression list
		  ;

// Defines a sequence of expressions
expr_seq :	expr ';'
		 |	expr ';' expr_seq
		 | expr error expr_seq // Error in expression sequence
		 | error  expr_seq // Error at the start of expression sequence
		 ;

// Defines case branches
case_branches :	case_branch
			  |	case_branch case_branches
			  | case_branch error case_branches // Error between case branches
			  ;

// Defines a single case branch
case_branch :	OBJECTID ':' TYPEID DARROW expr ';'
			| error // Error in case branch
			;

/* end of grammar */

%%

#include <FlexLexer.h>
extern yyFlexLexer	lexer;
int yylex(void)
{
	return lexer.yylex();
}

void yyerror(char *s)
{	
	extern ErrorMsg errormsg;
	errormsg.error(yylloc.first_line, yylloc.first_column, s);
}


