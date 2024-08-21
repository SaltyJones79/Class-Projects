(*
Programmer: Jeremy Saltz
Class: CSCI 4160
Due Date: 02/05/2024
Instructor: Dr. Zhijiang Dong

Program description:
    The following program in a simple stack machine written in COOL.
    The stack machine takes inputs from the user and makes a stack.
    The use either enters an INT, 'x', 'e', 'd', or '*'.
    INT is any integer, the 'x' is to exit the program, 'e' is to evaluate
    the stack and if there is a '*' character on the top of the stack then
    the machine with pop the '*' off of the stack and then multiply the next
    two numbers on the stack. The result is then pushed on top of the stack.
    'd' is to display what is on the stack.
*)

(*
   The class A2I provides integer-to-string and string-to-integer
conversion routines.  To use these routines, either inherit them
in the class where needed, have a dummy variable bound to
something of type A2I, or simpl write (new A2I).method(argument).
*)


(*
   c2i   Converts a 1-character string to an integer.  Aborts
         if the string is not "0" through "9"
*)
class A2I {

     c2i(char : String) : Int {
	if char = "0" then 0 else
	if char = "1" then 1 else
	if char = "2" then 2 else
        if char = "3" then 3 else
        if char = "4" then 4 else
        if char = "5" then 5 else
        if char = "6" then 6 else
        if char = "7" then 7 else
        if char = "8" then 8 else
        if char = "9" then 9 else
        { abort(); 0; }  -- the 0 is needed to satisfy the typchecker
        fi fi fi fi fi fi fi fi fi fi
     };

(*
   i2c is the inverse of c2i.
*)
     i2c(i : Int) : String {
	if i = 0 then "0" else
	if i = 1 then "1" else
	if i = 2 then "2" else
	if i = 3 then "3" else
	if i = 4 then "4" else
	if i = 5 then "5" else
	if i = 6 then "6" else
	if i = 7 then "7" else
	if i = 8 then "8" else
	if i = 9 then "9" else
	{ abort(); ""; }  -- the "" is needed to satisfy the typchecker
        fi fi fi fi fi fi fi fi fi fi
     };

(*
   a2i converts an ASCII string into an integer.  The empty string 
is converted to 0.  Signed and unsigned strings are handled.  The
method aborts if the string does not represent an integer.  Very
long strings of digits produce strange answers because of arithmetic 
overflow.
(*2019Spring*)
*)
     a2i(s : String) : Int {
        if s.length() = 0 then 0 else
	if s.substr(0,1) = "-" then ~a2i_aux(s.substr(1,s.length()-1)) else
        if s.substr(0,1) = "+" then a2i_aux(s.substr(1,s.length()-1)) else
           a2i_aux(s)
        fi fi fi
     };

(*
  a2i_aux converts the usigned portion of the string.  As a programming
example, this method is written iteratively.
*)
     a2i_aux(s : String) : Int {
	(let int : Int <- 0 in	
           {	
               (let j : Int <- s.length() in
	          (let i : Int <- 0 in
		    while i < j loop
			{
			    int <- int * 10 + c2i(s.substr(i,1));
			    i <- i + 1;
			}
		    pool
		  )
	       );
              int;
	    }
        )
     };

(*
    i2a converts an integer to a string.  Positive and negative 
numbers are handled correctly.  
*)
    i2a(i : Int) : String {
	if i = 0 then "0" else 
        if 0 < i then i2a_aux(i) else
          "-".concat(i2a_aux(i * ~1)) 
        fi fi
    };
	
(*
    i2a_aux is an example using recursion.
*)		
    i2a_aux(i : Int) : String {
        if i = 0 then "" else 
	    (let next : Int <- i / 10 in
		i2a_aux(next).concat(i2c(i - next * 10))
	    )
        fi
    };

};

-- modified the list class to act as a stack

class List {
   -- Define operations on empty lists.

   isNil() : Bool { true };

   -- Since abort() has return type Object and head() has return type
   -- Int, we need to have an Int as the result of the method body,
   -- even though abort() never returns.

   head()  : String { { abort(); "0"; } };

   -- As for head(), the self is just to make sure the return type of
   -- tail() is correct.

   tail()  : List { { abort(); self; } };

   -- When we cons and element onto the empty list we get a non-empty
   -- list. The (new Cons) expression creates a new list cell of class
   -- Cons, which is initialized by a dispatch to init().
   -- The result of init() is an element of class Cons, but it
   -- conforms to the return type List, because Cons is a subclass of
   -- List.

   cons(s : String) : List {
      (new Cons).init(s, self)
   };

   -- to print the current state of the stack
   print_list(l : List) : Object {
      if l.isNil() then (new IO).out_string("")
                   else {
			   (new IO).out_string(l.head());
			   (new IO).out_string("\n");
			   print_list(l.tail());
		        }
            fi
    };

    -- the evaluation function for when 'e' in entered.

    evaluate(l : List) : List {

        --if the top of the stack is '*' then the 
        --strings are convered to ints and multiplied
        --the result is then caste back to a string
        --and pushed onto the stack

        if l.head() = "*" then (
            let tempTail1 : List <- l.tail(),
                intStr1 : String <- tempTail1.head(),
                tempTail2: List <- tempTail1.tail(),
                intStr2 : String <- tempTail2.head(),
                remainder : List <- tempTail2.tail()
                
             in
             
                let int1 : Int <- (new A2I).a2i(intStr1),
                    int2 : Int <- (new A2I).a2i(intStr2),
                    result : Int <- int1 * int2,
                    resultStr : String <- (new A2I).i2a(result)
                in remainder.cons(resultStr)
                )
                else l 
                fi
    };

};

--works with the list class to 'push' and 'pop' the stack

class Cons inherits List {

   car : String;	-- The element in this list cell

   cdr : List;	-- The rest of the list

   isNil() : Bool { false };

   head()  : String { car };

   tail()  : List { cdr };

   init(s : String, rest : List) : List {
      {
	 car <- s;
	 cdr <- rest;
	 self;
      }
   };

};

class Main inherits A2I {

    --initializes the stack
    myStack : List <- new List;
    
    --entry point of the program and where the macig happens
    main(): Object {
        
        --starts the while loop and gets the first input from the user
        --it then loops until the user enters 'x' and then the loop ends
        --depending on the user inputs the machine will do different tasks
        --either call the print_list method, or the evaluate method, or add
        --to the stack, or exit the program.

        let input: String <- (new IO).out_string(">").in_string() in {

            while not (input = "x") loop {

                if input = "d" then myStack.print_list(myStack) else

                if (myStack.isNil()) then myStack <- myStack.cons(input) else
                if (input = "e") then myStack <- myStack.evaluate(myStack) else
                    myStack <- myStack.cons(input)
                    
                fi fi fi;

                (new IO).out_string(">");

                input <- (new IO).in_string();  -- Read next input

            } pool;
        }
    };
};
