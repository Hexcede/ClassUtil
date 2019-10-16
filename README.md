# ClassUtil
ClassUtil is a utility module aimed for ease of use with object oriented programming in Roblox. It uses zero metatables (better performance!) and is easy to use! It offers an easy and clean way to handle class inheritance.
See **Usage** section below.

## Installation
### Option 1 - With RoStrap framework (what I personally recommend for organization)
1. Install RoStrap (https://rostrap.github.io/Getting-Started/).
2. Run the plugin and select a framework location.
3. Insert the module into the framework `Packages` folder.
4. Use Resources:LoadLibrary("ClassUtil") to require it.
### Option 2 - With require
1. Insert the module somewhere
2. Locate and require the module

## Usage
Your class must use the following: `ClassUtil:Class(MyClass, [ParentClass])`. This creates a `.new` function for the supplied (or new combo) class. Your class *must* contain a `:Constructor()` method and it must be defined *before* `ClassUtil:Class()` is called in order for `.new` to work. The self argument of the Constructor function is the newly instantiated object (see below). The rest of the function arguments are passed from `.new` to the constructor function.

To create
```lua
local MyParentClass = {}
function MyParentClass:MyMethod(...)
	print("From MyParentClass", ...)
end
function MyParentClass:MyParentMethod(...)
	print("From MyParentClass (in parent method)", ...)
end
function MyParentClass:Constructor(...)
	self:MyMethod("Called by MyParentClass!")
	self.super:MyMethod(...) -- super still contains all MyClass methods and properties but not any inherited ones.
	self.super.super:MyParentMethod(...) -- super.super contains all parent (MyParentClass) class methods and properties but not any inherited ones.
end

ClassUtil:Class(MyParentClass) -- Must go after Constructor. Returns MyClass again.

local MyClass = {}

MyClass.ABC = 123

function MyClass:MyMethod2(...)
	print("From MyClass", ...) -- Prints arguments from MyClass.new(...)
end
function MyClass:MyMethod(...)
	self.super:MyMethod2(...) -- Super exists here too
end
function MyClass:MyParentMethod(...)
	error("You shouldn't see me because I'm overriden!")
end
function MyClass:Constructor(...)
	self.super:MyMethod(...) -- super contains all MyClass methods and properties but not any inherited ones.
end

local MyComboClass = ClassUtil:Class(MyClass, MyParentClass) -- Must go after Constructor. Returns copy of MyClass with its parent set to MyParentClass.

MyComboClass.new("abc123", "secondArg", 123)
```

Output:
```
From MyClass abc123 secondArg 123
From MyParentClass Called by MyParentClass!
From MyClass abc123 secondArg 123
From MyParentClass (in parent method) abc123 secondArg 123
```
