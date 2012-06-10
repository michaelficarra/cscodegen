{MemberAccessOp, DynamicMemberAccessOp, Identifier, String: CSString} = require 'CoffeeScriptRedux/lib/coffee-script/nodes'

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
