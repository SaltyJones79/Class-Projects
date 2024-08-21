/*
    Programer: Jeremy Saltz
    Class: CSCI 4160
    Project description:
    the following is a flex scaner generator for COOL programming language. 
    It will scan a piece of COOL code and return any type id's, object ids, tokens, error. it will also 
    recoginze and comments line or nested and ignore the context of the comment.
    It will recognize any unfiished strings or comments.  
    */
%option noyywrap
%option c++
%option never-interactive
%option nounistd
%option yylineno

%{
#include <iostream>
#include <string>
#include <sstream>
#include "tokens.h"
#include "ErrorMsg.h"

using std::string;
using std::stringstream;

ErrorMsg	errormsg;		//objects to trace lines and chars per line so that
							//error message can refer the correct location 
int		c_depth = 0;	// depth of the nested comment
string	buffer = "";		// the buffer to hold part of string that has been recognized

void newline(void);				//trace the line #
void error(int, int, string);	//output the error message referring to the current token

int			line_no = 1;		//line no of current matched token
int			column_no = 1;		//column no of the current matched token

int			tokenCol = 1;		//column no after the current matched token

int			beginLine=-1;		//beginning position of a string or comment
int			beginCol=-1;		//beginning position of a string or comment

//YY_USER_ACTION will be executed after each Rule is used. Good to track locations.
#define YY_USER_ACTION {column_no = tokenCol; tokenCol=column_no+yyleng;}
%}


/* defined regular expressions */
NEWLINE			[\n]
WHITESPACES		[ \t\f\v\r]
TYPESYMBOL		[A-Z][_A-Za-z0-9]*
OBJECTSYMBOL	[a-z][_A-Za-z0-9]*

/*exclusive start conditions to recognize comment and string */
%x COMMENT
%x LINE_COMMENT
%x STRING


%%
{NEWLINE}			{ newline(); } /* Match a newline character and call newline() function. */
{WHITESPACES}+		{} /* Ignore one or more whitespace characters. */



 /*
 * Rules for single character tokens.
 * These rules match single characters and return the character itself as a token.
 */

"+"	        { return '+'; }
"-"			{ return '-'; }
"*"			{ return '*'; }
"/"			{ return '/'; }
"{"			{ return '{'; }
"}"			{ return '}'; }
"("			{ return '('; }
")"			{ return ')'; }
":"			{ return ':'; }
","			{ return ','; }
"="			{ return '='; }
";"			{ return ';'; }
"."			{ return '.'; }
"~"         { return '~'; }

 /*
  *  The multiple-character operators.
  */
"=>"				{ return (DARROW); }
"<="				{ return (LE); }
"<-"				{ return (ASSIGN); }

 /*
  *  integers should be added to the "intTable" (check stringtab.h file) 
  *  so that there is only one copy of the same interger literal.
  *  Similarly, string literals should be added to "stringTable", and 
  *  typeid and objectid should be added to "idTable".
  *	 
  *	 yylval is a variable of YYSTYPE structure is used to hold values 
  *	 of tokens if a token is a collection of lexemes.
  *
  *  check YYSTYPE definition in tokens.h
  */

[0-9][0-9]*			{ yylval.symbol = intTable.add_string(YYText()); return INTCONST; }

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

  /* all the case-insensitive keyword tokens */
[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]		{ return (INHERITS); }
[Cc][Aa][Ss][Ee]			{ return (CASE); }
[Cc][Ll][Aa][Ss][Ss] 		{ return (CLASS); }
[Ee][Ll][Ss][Ee]			{ return (ELSE); }
[Ee][Ss][Aa][Cc]			{ return (ESAC); }
[Ll][Ee][Tt]				{ return (LET); }
[Ll][Oo][Oo][Pp]			{ return (LOOP); }
[Pp][Oo][Oo][Ll]			{ return (POOL); }
[Tt][Hh][Ee][Nn]			{ return (THEN); }
[Ww][Hh][Ii][Ll][Ee]		{ return (WHILE); }
[Oo][Ff]					{ return (OF); }
[Ii][Nn]					{ return (IN); }
[Ii][Ff]					{ return (IF); }
[Ff][Ii]					{ return (FI); }
[Nn][Ee][Ww]				{ return (NEW); }
[Nn][Oo][Tt]                { return (NOT); }
[t][Rr][Uu][Ee]             { return (BOOLCONST); }
[f][Aa][Ll][Ss][Ee]         { return (BOOLCONST); }
[Ii][Ss][Vv][Oo][Ii][Dd]    { return (ISVOID); }

    /* returns typeid and objectid*/
{TYPESYMBOL}		{ yylval.symbol = idTable.add_string(YYText()); return TYPEID; }
{OBJECTSYMBOL}		{ yylval.symbol = idTable.add_string(YYText()); return OBJECTID; }

 /*
  * Add all missing rules here
  *
  */

  /* Entery point for a string*/
\" {
    BEGIN(STRING);
    buffer.clear();
    beginCol = column_no;
 }

 /*Further definitions for strings*/
<STRING>{
    /* */
    [^"\\\n]+ { 
        buffer += YYText(); 
    }

    \\\n { 
        newline(); 
    }

    \\\\ { 
        buffer += '\\'; 
    }

    \\n { 
        buffer += '\n'; 
    }

    \\t { 
        buffer += '\t'; 
    }

    \\\" { 
        buffer += '\"'; 
    }

    \\[bf] { 
        buffer += (YYText()[1] == 'b') ? '\b' : '\f'; 
    }

    \\[^"ntbf\\] { 
        /* Report an error for an illegal escape sequence */
        error(line_no, column_no, string("\\") + YYText()[1] + " illegal escape sequence");
        /* Include the backslash and the following character in the buffer */
        buffer += "\\"; /* Backslash already included*/
        buffer += YYText()[1]; /* Append the character following the backslash */
    }

    \" {
        yylval.symbol = stringTable.add_string(buffer.c_str());
        BEGIN(INITIAL);
        return STRCONST; 
    }

    \n {
        /* Report an error for an unfinished string constant */
        error(line_no, beginCol, "Unterminated string constant");
        /* Add the current buffer as a string constant despite the error */
        yylval.symbol = stringTable.add_string(buffer.c_str());
        BEGIN(INITIAL);
        newline();
        return STRCONST;  /* Return the string constant token */
}
    <<EOF>> {
        /* Report an error for EOF encountered within a string */
        error(line_no, column_no, "EOF in string");
        /* Add the buffer as a string constant */
        yylval.symbol = stringTable.add_string(buffer.c_str());
        BEGIN(INITIAL);  
        return STRCONST; /* Return the string constant token */
    }
 }
    /* for a line comment*/
"--"[^\n]*		{   }

    /* entry point for the nested comments */
"(*"			{	/* entering comment */
					c_depth +=1;
					beginLine = line_no;
					beginCol = column_no;
					BEGIN(COMMENT);	
				}

    /* counts the depth of the comments to look for the match*/
<COMMENT>"(*"	{	/* nested comment */
					c_depth ++;
				}

<COMMENT>[^*)(\n]*	{	/*eat string that's not a '*', '(', ')' */ }

<COMMENT>"("+[^*)\n]*  {	/*eat string that starts with ( but not followed by '*' and ')' */ }

<COMMENT>[^*(\n]*")"+  {	/*eat string that doesn't contain '*' and '(' but ends with a sequence of ')' */ }

<COMMENT>"*"+[^*)(\n]*	{	/* eat string that starts with a sequence of * followed by anything other than '*', '(', ')' */	}

<COMMENT>\n		{	/* trace line # and reset column related variable */
					line_no++; 
					column_no = tokenCol = 1;
				}

<COMMENT>"*"+")"	{	/* close of a comment */
						c_depth --;
						if ( c_depth == 0 )
						{
							BEGIN(INITIAL);	
						}
					}
<COMMENT><<EOF>>	{	/* unclosed comments */
						error(beginLine, beginCol, "unclosed comments");
						yyterminate();
					}

<<EOF>>			{	yyterminate();	}

.				{	error(line_no, column_no, "illegal token"); 
				}



%%

void newline()
{
	line_no ++;
	column_no = 1;
	tokenCol = 1;
}

void error(int line, int col, string msg)
{
	errormsg.error(line, col, msg);
}
