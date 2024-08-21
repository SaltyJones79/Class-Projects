#include "Absyn.h"
#include "Semant.h"

/*Programmer: Jeremy Saltz
* Class: CSCI 4160
* Program discption:
* This program is a semantic analyzier for the cool program language. It takes a COOL program and reports any
* semantic errors.
*/
using namespace absyn;

Symbol	arg,
		arg2,
		Bool,
		concat,
		cool_abort,
		copy_,
		Int,
		in_int,
		in_string,
		IO,
		isProto,
		length,
		Main,
		main_meth,
		No_class,
		No_type,
		Object,
		out_int,
		out_string,
		prim_slot,
		self,
		SELF_TYPE,
		Str,
		str_field,
		substr,
		type_name,
		val;

void initialize_constants(void)
{
	arg = idtable.add_string("arg");
	arg2 = idtable.add_string("arg2");
	Bool = idtable.add_string("Bool");
	concat = idtable.add_string("concat");
	cool_abort = idtable.add_string("abort");
	copy_ = idtable.add_string("copy");
	Int = idtable.add_string("Int");
	in_int = idtable.add_string("in_int");
	in_string = idtable.add_string("in_string");
	IO = idtable.add_string("IO");
	isProto = idtable.add_string("isProto");
	length = idtable.add_string("length");
	Main = idtable.add_string("Main");
	main_meth = idtable.add_string("main");
	//   _no_class is a symbol that can't be the name of any
	//   user-defined class.
	No_class = idtable.add_string("_no_class");
	No_type = idtable.add_string("_no_type");
	Object = idtable.add_string("Object");
	out_int = idtable.add_string("out_int");
	out_string = idtable.add_string("out_string");
	prim_slot = idtable.add_string("_prim_slot");
	self = idtable.add_string("self");
	SELF_TYPE = idtable.add_string("SELF_TYPE");
	Str = idtable.add_string("String");
	str_field = idtable.add_string("_str_field");
	substr = idtable.add_string("substr");
	type_name = idtable.add_string("type_name");
	val = idtable.add_string("_val");
}

///////////////////////////////////////////////////////////////////////////////
//
//  Type Checking Features
//
//  For each class of expression, there is a tc method to typecheck it.
//  The tc methods make use of the environments previously constructred
//  for each class.  
//  Please implement the following type checking method.
//
//  YOU ARE NOT ALLOWED TO CALL tc_teacher VERSION
///////////////////////////////////////////////////////////////////////////////

void Attr::tc_student(EnvironmentP env)
{
	//your implementation here
	
	//Attribute declaration format
	//name : type_decl <- init
	
	/*
		Algorithm:
			if type_decl doesn't exists as a class, report an error

			if init is provided
				Perform type checking on init and save its type info
				if the type of init is not compatible with type_decl, then report an error
	*/

	// Check if the type declared for the attribute exists in the class hierarchy
	if (!env->lookup_class(type_decl)) {
		env->semant_error(this) << "Type " << type_decl << " declared for attribute " << name << " does not exist." << endl;
		return;
	}

	// If there is an initialization expression, type check it
	if (init != nullptr) {
		Symbol init_type = init->tc(env); // Preform type checking on the init expression
		if (!env->type_leq(init_type, type_decl)) { // Check if the type of init conforms to type_decl
			env->semant_error(this) << "Type " << init_type << " of initialization does not conform to declared type "
				<< type_decl << " of attribute " << name << "." << endl;
		}
	}
}


Symbol IntExp::tc_student(EnvironmentP)
{
	type = Int;
	return Int;
}

Symbol BoolExp::tc_student(EnvironmentP)
{
	type = Bool;
	return Bool;
}

Symbol StringExp::tc_student(EnvironmentP)
{
	type = Str;
	return Str;
}

Symbol OpExp::tc_student(EnvironmentP env)
{
	//your implementation here
	
	//OpExp format:
	// left op right
	
	/*
		Algorithm:
			perform type checking on left and save its return value to ltype
			perform type checking on right and save its return value to rtype
			
			if op is not EQ
				if ltype or rtype is not Int, report an error
				
			else
				if t1 is not the same as t2 and t1 or t2 is Int, Bool, or Str
					report an error
			
			if op is LT, LE, or EQ
				set attribute type to Bool
			else
				set attribute type to Int

		
	*/

	// Type check both the left and right expressions
	Symbol ltype = left->tc(env);
	Symbol rtype = right->tc(env);
	string op_str = "";  // To store the string representation of the operation

	switch (op) {
	case PLUS:
	case MINUS:
	case MUL:
	case DIV:
		op_str = (op == PLUS) ? "+" : (op == MINUS) ? "-" : (op == MUL) ? "*" : "/";
		if (ltype != Int || rtype != Int) {
			env->semant_error(this) << "Incompatible types for  " << ltype << " " << op_str << " " << rtype << endl;
			type = Int;
		}
		else {
			type = Int;
		}
		break;
	case LT:
	case LE:
	case EQ:
		op_str = (op == LT) ? "<" : (op == LE) ? "<=" : "==";
		if ((ltype != rtype) && ((ltype == Int || ltype == Bool || ltype == Str) && (rtype == Int || rtype == Bool || rtype == Str))) {
			env->semant_error(this) << "Incompatible types for "  << ltype << " " << op_str << " " << rtype << endl;
			type = No_type;
		}
		else {
			type = Bool;
		}
		break;
	default:
		env->semant_error(this) << "Unsupported operator." << endl;
		type = No_type;
		break;
	}
	return type;
}


Symbol NotExp::tc_student(EnvironmentP env)
{
	//your implementation here
	//NotExp format:
	//	NOT expr
	/*
		perform type checking on expr and save its return type to t
		
		if t is not the same as Bool	
			report an error
		
		set attribute type to Bool
	*/

	// Perform type checking on the expression and save its return type
	Symbol t = expr->tc(env);

	// Check if the return type is not Bool
	if (t != Bool) {
		// Report an error if the type of expr is not Bool
		env->semant_error(this) << "Argument of 'not' has type " << t << " instead of Bool." << endl;
		type = Bool;  // Indicate an error in type checking
	}
	else {
		// If no error, set the type of this expression to Bool
		type = Bool;
	}

	return type;
}

Symbol ObjectExp::tc_student(EnvironmentP env)
{
	//your implementation here
	
	//ObjectExp format:
	//	name
	
	/*
		if the variable name exists
			lookup the variable  in symbol table and save its type information to attribute type
		else
			report an error (undeclared identifier)
			set attribute type to Object
	*/

	// Check for variable name in the symbol table
	if (env->var_lookup(name)) {
		// If found type is variable type
		type = env->var_lookup(name);
	}
	else {
		// If variable not found, error 
		env->semant_error(this) << "Undeclared identifier '" << name << "'." << endl;
		type = Object;
	}

	return type;
}

Symbol NewExp::tc_student(EnvironmentP env)
{
	//your implementation here
	
	//NewExp format:
	//	new type_name
	
	/* Algorithm:
		lookup the class table to check if the type_name exists
		if exists
			set attribute type to type_name
		else
			report an error of undefined class
			set attribute type to Object
	*/

	// Check if the class name exists in the class table
	if (env->lookup_class(type_name)) {
		// if is exists type = type_name
		type = type_name;
	}
	else {
		// class does not exist: error
		env->semant_error(this) << "Undefined class '" << type_name << "' used in new op." << endl;
		type = Object;
	}

	return type;
}

Symbol IsvoidExp::tc_student(EnvironmentP env)
{
	//your implementation here
	//IsvoidExp format:
	//	isvoid(expr)
	
	/*
		Algorithm:
			perform type checing on expr;
			set attribute type to Bool
	*/

	Symbol expr_type = expr->tc(env);

	type = Bool;

	return type;
}

Symbol LetExp::tc_student(EnvironmentP env)
{
	//your implementation here
	
	//LetExp format
	//let identifier : type_decl <- init in body
	
	/*
		Algorithm:
		lookup type_decl in class table to check if it exists.
		if it doesn't exist, report an error of undeclared class
		
		if init is provided
			perform type checking on init
			if the type of init is not compatible with type_decl
				report an error of type mismatch
		
		enter a new scope for variables
		
		if identifier is the same as self
			report an error
		else
			insert the variable and its type into variable symbol table
		
		perform type checking on body and save the return value to attribute type
		
		exit the current scope for variables
		
	*/

	// check class table for type_decl
	if (!env->lookup_class(type_decl)) {
		env->semant_error(this) << "Undeclared type " << type_decl << " in let expression." << endl;
		type = No_type;
		return type;
	}

	// if init is provided check type
	if (init != nullptr) {
		Symbol init_type = init->tc(env); // type check init expression
		if (!env->type_leq(init_type, type_decl)) {
			env->semant_error(this) << "Type of initialization expression " << init_type
				<< " does not conform to declared type " << type_decl << "." << endl;
		}
	}

	// enter new scope
	env->var_enterScope();

	// Check if identifier is 'self', not allowed to redeclare
	if (identifier == self) {
		env->semant_error(this) << "Cannot bind 'self' in a let expression." << endl;
	}
	else {
		// Insert the new variable and type to the var symbol table
		env->var_add(identifier, type_decl);
	}

	// type checking on body in new scope 
	Symbol body_type = body->tc(env);

	// exit scope
	env->var_exitScope();

	type = body_type;

	return type;
}

Symbol BlockExp::tc_student(EnvironmentP env)
{
	//your implementation here
	
	/* Algorithm:
		for each expression in the list
			perform type checking on the expression and save its return value to attribute type
	*/
	Symbol last_type = No_type;  // To store the type of the last evaluated expression
	List<Expression>* current = body;  // Pointer to the first list element

	while (current != nullptr) {
		Expression expr = current->getHead();  // Get the current expression pointer
		last_type = expr->tc(env);  // Perform type checking on this expression
		current = current->getRest();  // Move to the next element in the list
	}

	type = last_type;  // The type of the block expression is the type of the last expression in the list
	return type;
}


Symbol AssignExp::tc_student(EnvironmentP env)
{
	//Solution given
	
	//AssignExp format:
	//	name <- expr

	//if name is self, report an error
	if (name == self)
		env->semant_error(this) << "Cannot assign to 'self'." << endl;

	//if name is not defined as a variable, report an error
	if (!env->var_lookup(name))
		env->semant_error(this) << "Assignment to undeclared variable " << name
		<< "." << endl;

	//perform type checking on expr and save its return value to attribute type
	type = expr->tc(env);

	//if type of the expression is not compatible with variable type, report an error 
	if (!env->type_leq(type, env->var_lookup(name)))
		env->semant_error(this) << "Type " << type <<
		" of assigned expression does not conform to declared type " <<
		env->var_lookup(name) << " of identifier " << name << "." << endl;

	//return the type of AssignExp
	return type;

}

Symbol CallExp::tc_student(EnvironmentP env)
{
	//No need to implement this method
	return No_type;
}

Symbol StaticCallExp::tc_student(EnvironmentP env)
{
	//No need to implement this method
	return No_type;
}


Symbol IfExp::tc_student(EnvironmentP env)
{
	//your implementation here

	//IfExp format:
	// if pred 
	//	then then_exp
	//	else else_exp

	/* Algorithm:
		perform type checking on pred, if return value is NOT Bool, report an error
		
		perform type checking on then_exp and save the return value, say then_type
		perform type checking on else_exp and save the return value, say else_type
		
		set attribute type to the lub of then_type and else_type
	*/

	// Type check the predicate expression
	Symbol pred_type = pred->tc(env);
	if (pred_type != Bool) {
		env->semant_error(this) << "Predicate of 'if' expression must be Boolean, found type " << pred_type << "." << endl;
		type = No_type;
		return type;
	}

	// Type check the 'then' expression
	Symbol then_type = then_exp->tc(env);

	// Type check the 'else' expression
	Symbol else_type = else_exp->tc(env);

	// Determine the type of the 'if' expression by finding the least upper bound of then and else expressions
	type = env->type_lub(then_type, else_type);

	return type;
}

Symbol WhileExp::tc_student(EnvironmentP env)
{
	//your implementation here

	//WhileExp format: 
	// while pred
	//		body
	
	/* Algorithm:
		perform type checking on pred, if return value is NOT Bool, report an error
		
		perform type checking on body
		
		set attribute type to Object
	*/
	// Type check the predicate expression
	Symbol pred_type = pred->tc(env);
	if (pred_type != Bool) {
		env->semant_error(this) << "Predicate of 'while' loop must be Boolean, found type " << pred_type << "." << endl;
		type = No_type;
		return type;
	}

	// Type check the body expression, the type of the body does not affect the type of the while loop
	body->tc(env);

	// The type of a 'while' loop in Cool is always Object, regardless of the body's type
	type = Object;
	return Object;
}

Symbol Branch_class::tc_student(EnvironmentP env)
{
	//No need to implement
	return expr->tc(env);
}

Symbol CaseExp::tc_student(EnvironmentP env)
{
	//No need to implement this
	return No_type;
}

void Method::tc_student(EnvironmentP env)
{
	//No need to implement this
}

void Formal_class::tc_student(EnvironmentP env)
{
	//No need to implement this
}

Symbol NoExp::tc_student(EnvironmentP)
{
	type = No_type;
	return No_type;
}