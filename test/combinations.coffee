{Program, Block, AssignOp, Identifier, Function: CSFunction, FunctionApplication, MultiplyOp, AddOp} = require 'CoffeeScriptRedux/lib/coffee-script/nodes'

# program . assignment . application . function . maths . maths
eq 'a = ((x, y) -> x * (y + z)) b'
, generate new Program new Block [
  new AssignOp (new Identifier "a"),
  new FunctionApplication (new CSFunction [(new Identifier "x"), (new Identifier "y")], new Block [
    new MultiplyOp (new Identifier "x"), new AddOp (new Identifier "y"), (new Identifier "z")
  ]), [new Identifier "b"]
]
