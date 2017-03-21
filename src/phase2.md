API & UX Round Two Sketch
=========================

This doc is meant to elaborate on and help establish the design for the next API
refinement, including ergonomic and functional aspects.
 
With the current API, it is difficult to think about *related* data. There are a
few kinds of related data that we can consider. The focus for now is on *nested*
data. For an example, consider 10-to-1 associations over a large set of
entities. It is also difficult to efficiently re-use partially computed data that
may be re-used in many places.

## Challenges

**Modeling Associations** 

It is difficult to express the 10-to-1 association in a way that is intuitive.
The present methods rely too much on knowledge of the underlying math. This
isn't bad for those who have the knowledge, but it is for those who just want to
express an association between values.

This brings us to a couple of necessarily related challenges:

**Reusing Recipes**

There is no common format for sharing a group of data mapping functions. This
means that common recipes that might be useful are not easily reused.

**Implementing Standard Libraries**

There is no standard grammar. After some use, the ad-hoc nature of the resolver
interface is starting to become obviously cumbersome -- requiring strong
dependence on base library types in the core API. This dependence is not
inherently bad, but it the reason for it is. The current library interface is
just too complex. It would be better at this point to refactor the core API
around a set of language concepts that are easy to edit as well as easy to model
at runtime.

**Runtime Efficiency**

It is difficult to efficiently track intermediate state of generated data, such
as a common identifier on the "one" side of a 10-to-1 association. By requiring
users to use the same prefix logic (inner functions) in their recipes, many values
are recomputed at every field on an entity. 

# Design Sketch

From the above, the following design imperatives are taken:

1. Build a proper grammar that allows for DAG-structured function dependencies --
   one that is easy to read and modify.
2. Allow results to be accessed by name, and cached when appropriate by the runtime.
3. Allow named variable dependencies such that downstream functions can express
  a named dependency on common upstream functions.
4. Provide an efficient runtime accessor that does iterate on map accesses, but which
  still allows for name-based resolution of values.
5. Provide a direct method for understanding the dependencies and calling options
  for a set of mapping functions.
  
The language of VDS should be a recipe-level language. It should also give some
leverage to the runtime to find the best functions to use in fulfilling the
request. For simple cases, the recipe should be simple and obvious. For more
ambitious efforts, the language should allow for finer control.

## New Concepts

**Standard Language**
All recipes must now follow the new syntax. It is mostly compatible with the old syntax,
  although stricter about values, etc.

**Data Mapping Expressions**
All 


## Design Approaches

### #1 Intuitive Expression of Associations

In order to represent nested associations of data values in a more intuitive
fashion, any implicit nesting should be banished and replaced with an explicit
nesting format. This simply means that the nesting must be structurally and
visually apparent in the native configuration format, and that the result of
using such configuration should be equally obvious.

In short, make the configuration format nested and structurally equal to the
associations in the values that will be generated.

#### Design Strategy

1. Provide a configuration format that allows different levels of nesting
   to be expressed.

### #2 Efficient Runtime Representation and API

Given the need to organize data mapping functions in a way that can support
nested iteration, there is a scope of data that will remain fixed at outer
levels while inner levels have changing data per iteration.

Nested configuration structure can easily support nested iteration of
mapping functions.

Also, it is reasonable to expect that developers want to access directly
these names, but without paying for a map access every time.

#### Design Strategy


1. Provide a context and API for managing named and nested scopes of mapping 
   functions
1. Provide an internal cache in the runtime for named values.
2. Make the cache design straight-forward enough for 
2. Allow a mapper to use a value from the provided scope as the input value.
3. Enable access to the generated values through an efficient naming interface.
4. Do not rely on maps. If necessary, provide a cachable/reusable lookup
   interface that relies on arrays in the worst case.


### #3 Standard Grammar

### #4 Standard File Format






