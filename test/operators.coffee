# a.b[c]['d'].e
eq 'a.b[c][\'d\'].e'
, generate (
  new MemberAccessOp (
    new DynamicMemberAccessOp (
      new DynamicMemberAccessOp (
        new MemberAccessOp (new Identifier "a"), new Identifier "b"
      ), new Identifier "c"
    ), new CSString "d"
  ), new Identifier "e"
)

eq '(->)?', generate new UnaryExistsOp new CSFunction [], new Block []

eq 'new ->', generate new NewOp (new CSFunction [], new Block []), []

eq 'new (->) 0, 1', generate new NewOp (new CSFunction [], new Block []), [(new Int 0), new Int 1]

eq 'new F 0', generate new NewOp (new Identifier 'F'), [new Int 0]

eq 'new (F 0) 1', generate new NewOp (new FunctionApplication (new Identifier 'F'), [new Int 0]), [new Int 1]

eq '+->', generate new UnaryPlusOp new CSFunction [], new Block []

eq '(->) % 0', generate new RemOp (new CSFunction [], new Block []), new Int 0

eq '->; 0', generate new SeqOp (new CSFunction [], new Block []), new Int 0
