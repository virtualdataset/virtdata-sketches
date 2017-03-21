# VirtData Language


## Status

This doc is in design sandbox mode for now. If and when the ideas represented
here are implemented in VirtData, this will be come the template for the
accompanying documentation.

## Concepts

The VirtData syntax is *not* a direct programming language. It does not directly
produce values nor cause immediate side effects when run. Instead, it serves
as a templating system for combining functions into a function graph.

The syntax is incremental -- You only have to use as much of it as necessary.
The minimal amount of syntax is what is required to simply ask for a function by
name, 'Func1()' for example. This would represent a single function.

VirtData syntax doesn't care about whitespace. All newlines, carraige returns,
form feeds, tabs and spaces are ignored.

**Recipe**

A virtdata configuration is called a recipe. Recipes are sequences of flows.

**Flow**

A flow is a sequence of expressions that, together, form a processing pipeline.
Data flows in on the left side, and is provided as output on the right side.
Flows are delimited from each other by double-semicolon.

**Expression**

An expression is a function template, and as such must contain at least a
function name (including parenthesis). Expressions are delimited from each
other with a single semicolon.

## Configuration Structure

In summary, you make expressions out of function calls, which you can combine
together to make flows. You combine flows together to make a recipe.
The reason for combining flows together in a recipe will become clear below.

## Syntax

*Note:* in the diagrams below, the *name:=* formatted fields are not part of
the syntax. They are there to illustrate the syntax better.

A virtdata recipe consists of one or more flows, each consisting of one or more
expressions:

{{#railroad
ComplexDiagram( 
    'recipe:=',
    OneOrMore(
      Sequence(
       'flow:=',
       OneOrMore('expression',';')
      ,';;'   
      )
    )
).addTo();
}} 

For example, all of the following structures are equivalent in terms of expression 
delimiters (semicolon) and flow delimiters (double-semicolon):

~~~
e1() ;;
e2() ; e3() ; e4()
~~~

~~~
e1() ;; e2() ; e3() ; e4()
~~~

~~~
e1() ;;
e2() ;
e3() ;
e4() ;
~~~

The first flow has one expression, "e1()", and the next has the other three.
Let's fill in some details on what an expression really is.


{{#railroad
ComplexDiagram(
    'expression:=',
    OneOrMore( 
      Stack(    
       Optional(Sequence('variable', '=')), 
       Optional(Sequence('input type','>-')),
       Sequence('function name','(',
        ZeroOrMore(  
         Choice(1,
          Sequence('$','varname'), '0.12E34','567','\'eight\'','<another function>'  
         ), ',' 
        )
        ,')'), 
       Optional(Sequence('->','output type'))      
      ), ';' 
    ) 
).addTo();
}}

Essentially, an expression in virtdata is a template for a function call, with optional input
and output type qualifiers, and an optional variable assignment to capture the output.
Notice that a function can contain other functions as arguments.

## Expression Details.

**Functions templates are named.**

~~~
Func1()
~~~

Function templates are specified by name, but must include parenthesis.
Functions are the core building block of expressions in VirtData, thus the only
required element of an expression.

**Input Type constraints are optional.**

~~~
Func1() -> Vampire
~~~

This rather scary expression template requires that Func1() have a return type
of *Vampire*.

**Output Type constraints are optional.**

~~~
Human >- Func1()
~~~

This expression template requires that Func1() accept an input type of *Human*.

**Variable assignments are optional.**

~~~
zapp=Func1();
~~~

In this recipe, when Func1() is called, the result is stored in the variable *zapp*.

**Arguments are optional.**

~~~
zapp=Func1(42);;
Func2($zapp,1.2E42,'snark');
~~~

In this case, the first function has an integer argument 42. The second has 3 arguments --
a variable reference, a float, and a string literal.

**A Note on Arguments**

The above example might not make much sense if you are expecting virtdata to be
a direct programming language. Virtdata is a function graph construction kit.
Function graphs are trees (directed acyclic graphs) of unary operators that are
connected. As unary operators, the functions in the function graph have a single
input and a single output.  Take for example, the following C function signature:

~~~
int func3(int i) ...
~~~

You know that this function takes an integer and yields an integer. In virtdata,
we go up a level in abstraction to say that our functions take "a value" and
yield "a value".  The data that flows between the operators is an intrinsic part
of the graph structure. So, we default to leaving out the obvious connection
from function to function -- the unary data flow. We know it's there.

So, what are the arguments for? There are two reasons, and thus two kinds of arguments:
1. To parameterize pure functions.
2. To rewire the graph topology.

When you provide a variable reference to a function definition, you are rewiring the
graph topology. For example, if you wanted to create a single operator that supports
two different downstream operators in separate flows, you can do it like this:

~~~
a=FX(); FY(); FZ($a);;
~~~

This is logically the same:

~~~ 
FX();FY();;
FX();FZ();;
~~~

However, it is not the same in one very important way. The single flow example
above will provide a single root graph in which the downstream operators depend
on the value stored in $a. The two-flow example below will have to independent
outputs.

Why does this matter? As they are shown, you can't get at the value from FY() in
the first example, as it is inline in the flow. Let's provide a more robust example:

~~~
w=FW(); x=FX(); y=FY(); z=FZ();;
a=FA(); b=FB(); c=FC($a);;
~~~

In this example, every possible function output has been named with variable
assignments. Every intermediate step in both flows is named, and therefore
accessible by the user API.

So then, why would we want to name these things? It is because sometimes you
want to see the intermediate values as a user. Sometimes, you want to see the
values that other data depends on in a carefully organized way. To provide a
clearer example, sometimes you want to emulate one-to-many or many-to-one
associations without recomputing all the intermediate values for every field you
generate.

How this works in practical terms will be explained below in more detail.

**Flow Wiring vs. Initializers**

Because variables and variable references are specifically about flow wiring,
what are the other arguments to a function definition? They are merely function
initializers. For example, if you wanted to allow for modulo division by some
integer value, "Mod(3)" does this, and is a pure function. Likewise for any
Mod(n), as long as once you define the function, you don't change the value of n.

The virtdata runtime will create a function object for each definition it fines,
initializing it with the non-flow arguments. In summary, arguments of the form
$val are always flow wiring arguments, and reroute the input to a function from
a named variable. All other arguments parameterize an instance of a function
object.

## Flow Semantics

Let's make a more comprehensive example from the above and illustrate it in
a proper function graph.

~~~
w=FW(); x=FX(); y=FY(); z=FZ();;
a=FA(); b=FB(); c=FC($a); d=FD($a);
~~~

{{#nomnoml
#zoom:1.0
#direction:down
#.function: fill=#FFFFFF visual=sender
#.userid: visual=frame
#.firstname: visual=frame
#.lastname: visual=frame
[<function>FW()]
[<function>FX()]
[<function>FY()]
[<function>FZ()]
[<function>FA()]
[<function>FB()]
[<function>FC()]
[<function>FD()]
[<input>coordinate] ->[<function>FW()]
[<input>coordinate] ->[<function>FA()]
[FA()]->[a]
[FB()]->[b]
[FC()]->[c]
[FD()]->[d]
[a]->[FC()]
[a]->[FD()]
[FW()] ->[w]
[FX()] ->[x]
[FY()] ->[y]
[FZ()] ->[z]
[FW()] ->[FX()]
[FX()] ->[FY()]
[FY()] ->[FZ()]
[FA()] ->[FB()]
}}       

This function graph template raises some interesting questions.

* What does it mean for a function to flow directly to another function?
* Why does FC() and FD() go indirectly through flow variable *a*, whiel FB() is connected directly to FA()?
* What values are we actually getting from this thing, anyway?

Let's answer them in turn.

First, FC() was wired explicitly 

