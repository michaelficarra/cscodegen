suite 'Combinations', ->

  test 'program . assignment . application . function . maths . maths', ->
    eq 'a = ((x, y) -> x * (y + z)) b'
    , generate new Program new Block [
      new AssignOp (new Identifier "a"),
      new FunctionApplication (new CSFunction [(new Identifier "x"), (new Identifier "y")], new Block [
        new MultiplyOp (new Identifier "x"), new PlusOp (new Identifier "y"), (new Identifier "z")
      ]), [new Identifier "b"]
    ]
