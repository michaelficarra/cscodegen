suite 'Operators', ->

  setup ->
    @emptyBlock = new Block []
    @emptyFunction = new CSFunction [], @emptyBlock
    @zero = new Int 0
    @one = new Int 1
    @[letter] = new Identifier letter for letter in ['a', 'b', 'c', 'd', 'e', 'f', 'F']


  test 'unary prefix operators', ->
    eq '++0', generate new PreIncrementOp @zero
    eq '--0', generate new PreDecrementOp @zero
    eq '+0', generate new UnaryPlusOp @zero
    eq '+(+0)', generate new UnaryPlusOp new UnaryPlusOp @zero
    eq '-0', generate new UnaryNegateOp @zero
    eq '-(-0)', generate new UnaryNegateOp new UnaryNegateOp @zero
    eq 'not 0', generate new LogicalNotOp @zero
    eq '!!0', generate new LogicalNotOp new LogicalNotOp @zero
    eq '!!!0', generate new LogicalNotOp new LogicalNotOp new LogicalNotOp @zero
    eq '~0', generate new BitNotOp @zero
    eq 'do 0', generate new DoOp @zero
    eq 'typeof 0', generate new TypeofOp @zero
    eq 'new 0', generate new NewOp @zero, []

  test 'unary prefix operators and function literals', ->
    eq '+->', generate new UnaryPlusOp @emptyFunction
    eq 'new ->', generate new NewOp @emptyFunction, []

  test 'unary prefix operators and function application', ->
    eq 'not f 0', generate new LogicalNotOp new FunctionApplication @f, [@zero]
    eq 'new F 0', generate new NewOp @F, [@zero]
    eq 'new (F 0) 1', generate new NewOp (new FunctionApplication @F, [@zero]), [@one]

  test 'unary prefix operators and application of function literals', ->
    eq 'new (->) 0, 1', generate new NewOp @emptyFunction, [@zero, @one]


  test 'unary postfix operators', ->
    eq '0?', generate new UnaryExistsOp @zero
    eq '0++', generate new PostIncrementOp @zero
    eq '0--', generate new PostDecrementOp @zero

  test 'unary postfix operators and function literals', ->
    eq '(->)?', generate new UnaryExistsOp @emptyFunction

  test 'unary postfix operators and function application', ->
    eq '(f 0)?', generate new UnaryExistsOp new FunctionApplication @f, [@zero]
    eq 'f()?', generate new UnaryExistsOp new FunctionApplication @f, []


  test 'unary prefix operators and unary postfix operators', ->
    eq '+0++', generate new UnaryPlusOp new PostIncrementOp @zero
    eq '(+0)++', generate new PostIncrementOp new UnaryPlusOp @zero
    eq 'new (F?)', generate new NewOp (new UnaryExistsOp @F), []
    eq '(new F)?', generate new UnaryExistsOp new NewOp @F, []


  test 'binary operators', ->
    eq '0; 1', generate new SeqOp @zero, @one
    eq '0 or 1', generate new LogicalOrOp @zero, @one
    eq '0 and 1', generate new LogicalAndOp @zero, @one
    eq '0 | 1', generate new BitOrOp @zero, @one
    eq '0 ^ 1', generate new BitXorOp @zero, @one
    eq '0 & 1', generate new BitAndOp @zero, @one
    eq '0 is 1', generate new EQOp @zero, @one
    eq '0 isnt 1', generate new NEQOp @zero, @one
    eq '0 < 1', generate new LTOp @zero, @one
    eq '0 <= 1', generate new LTEOp @zero, @one
    eq '0 > 1', generate new GTOp @zero, @one
    eq '0 >= 1', generate new GTEOp @zero, @one
    eq '0 in 1', generate new InOp @zero, @one
    eq '0 of 1', generate new OfOp @zero, @one
    eq '0 instanceof 1', generate new InstanceofOp @zero, @one
    eq '0 << 1', generate new LeftShiftOp @zero, @one
    eq '0 >> 1', generate new SignedRightShiftOp @zero, @one
    eq '0 >>> 1', generate new UnsignedRightShiftOp @zero, @one
    eq '0 + 1', generate new PlusOp @zero, @one
    eq '0 - 1', generate new SubtractOp @zero, @one
    eq '0 * 1', generate new MultiplyOp @zero, @one
    eq '0 / 1', generate new DivideOp @zero, @one
    eq '0 % 1', generate new RemOp @zero, @one
    eq 'a = 0', generate new AssignOp @a, @zero

  test 'negated binary operators', ->
    eq '0 not in 1', generate new LogicalNotOp new InOp @zero, @one

  test 'binary operators and function literals', ->
    eq '(->) % 0', generate new RemOp @emptyFunction, @zero
    eq '0 % ->', generate new RemOp @zero, @emptyFunction
    eq '->; 0', generate new SeqOp @emptyFunction, @zero
    eq '0; ->', generate new SeqOp @zero, @emptyFunction

  test 'binary operators and function application', ->
    eq 'f() % 0', generate new RemOp (new FunctionApplication @f, []), @zero
    eq '(f 0) % 1', generate new RemOp (new FunctionApplication @f, [@zero]), @one
    eq '0 % f 1', generate new RemOp @zero, new FunctionApplication @f, [@one]
    eq 'f 0 % 1', generate new FunctionApplication @f, [new RemOp @zero, @one]

  test 'binary operators and unary operators on functions', ->
    eq '(do ->) % 0', generate new RemOp (new DoOp @emptyFunction), @zero


  test 'compound assignment operators', ->
    eq 'a += 0', generate new CompoundAssignOp PlusOp, @a, @zero
    eq 'a or= 0', generate new CompoundAssignOp LogicalOrOp, @a, @zero
    eq 'a &= 0', generate new CompoundAssignOp BitAndOp, @a, @zero
    eq 'a >>>= 0', generate new CompoundAssignOp UnsignedRightShiftOp, @a, @zero


  test 'static member access operators', ->
    eq 'a.b', generate new MemberAccessOp @a, 'b'
    eq 'a.b.c', generate new MemberAccessOp (new MemberAccessOp @a, 'b'), 'c'
    eq 'f()?.a', generate new SoakedMemberAccessOp (new FunctionApplication @f, []), 'a'
    eq '(f 0)::a', generate new ProtoMemberAccessOp (new FunctionApplication @f, [@zero]), 'a'
    eq '(->)?::a', generate new SoakedProtoMemberAccessOp @emptyFunction, 'a'
    eq '(-> 0).a', generate new MemberAccessOp (new CSFunction [], new Block [@zero]), 'a'
    eq '(new F).b', generate new MemberAccessOp (new NewOp @F, []), 'b'
    eq '(new F 0).b', generate new MemberAccessOp (new NewOp @F, [@zero]), 'b'

  test 'dynamic member access operators', ->
    eq 'a[0]', generate new DynamicMemberAccessOp @a, @zero
    eq 'a[0][1]', generate new DynamicMemberAccessOp (new DynamicMemberAccessOp @a, @zero), @one
    eq 'a?[\'b\']', generate new SoakedDynamicMemberAccessOp @a, new CSString 'b'
    eq 'a::[c = 0]', generate new DynamicProtoMemberAccessOp @a, new AssignOp @c, @zero
    eq 'a?::[0; 1]', generate new SoakedDynamicProtoMemberAccessOp @a, new SeqOp @zero, @one
    eq 'f()[0]', generate new DynamicMemberAccessOp (new FunctionApplication @f, []), @zero
    eq '(f 0)[0]', generate new DynamicMemberAccessOp (new FunctionApplication @f, [@zero]), @zero
    eq '(->)[0]', generate new DynamicMemberAccessOp @emptyFunction, @zero
    eq '(-> 0)[0]', generate new DynamicMemberAccessOp (new CSFunction [], new Block [@zero]), @zero
    eq '(new F)[0]', generate new DynamicMemberAccessOp (new NewOp @F, []), @zero
    eq '(new F 0)[1]', generate new DynamicMemberAccessOp (new NewOp @F, [@zero]), @one

  test 'combinations of static/dynamic member access operators', ->
    eq 'a.b[c]::d', generate new ProtoMemberAccessOp (new DynamicMemberAccessOp (new MemberAccessOp @a, 'b'), @c), 'd'
