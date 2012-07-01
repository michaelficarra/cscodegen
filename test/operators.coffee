# unary prefix operators
eq '++0', generate new PreIncrementOp new Int 0
eq '--0', generate new PreDecrementOp new Int 0
eq '+0', generate new UnaryPlusOp new Int 0
eq '+(+0)', generate new UnaryPlusOp new UnaryPlusOp new Int 0
eq '-0', generate new UnaryNegateOp new Int 0
eq '-(-0)', generate new UnaryNegateOp new UnaryNegateOp new Int 0
eq 'not 0', generate new LogicalNotOp new Int 0
eq '!!0', generate new LogicalNotOp new LogicalNotOp new Int 0
eq '!!!0', generate new LogicalNotOp new LogicalNotOp new LogicalNotOp new Int 0
eq '~0', generate new BitNotOp new Int 0
eq 'do 0', generate new DoOp new Int 0
eq 'typeof 0', generate new TypeofOp new Int 0
eq 'new 0', generate new NewOp (new Int 0), []

# unary prefix operators and function literals
eq '+->', generate new UnaryPlusOp new CSFunction [], new Block []
eq 'new ->', generate new NewOp (new CSFunction [], new Block []), []

# unary prefix operators and function application
eq 'not f 0', generate new LogicalNotOp new FunctionApplication (new Identifier 'f'), [new Int 0]
eq 'new F 0', generate new NewOp (new Identifier 'F'), [new Int 0]
eq 'new (F 0) 1', generate new NewOp (new FunctionApplication (new Identifier 'F'), [new Int 0]), [new Int 1]

# unary prefix operators and application of function literals
eq 'new (->) 0, 1', generate new NewOp (new CSFunction [], new Block []), [(new Int 0), new Int 1]


# unary postfix operators
eq '0?', generate new UnaryExistsOp new Int 0
eq '0++', generate new PostIncrementOp new Int 0
eq '0--', generate new PostDecrementOp new Int 0

# unary postfix operators and function literals
eq '(->)?', generate new UnaryExistsOp new CSFunction [], new Block []

# unary postfix operators and function application
eq '(f 0)?', generate new UnaryExistsOp new FunctionApplication (new Identifier "f"), [new Int 0]
eq 'f()?', generate new UnaryExistsOp new FunctionApplication (new Identifier "f"), []


# unary prefix operators and unary postfix operators
eq '+0++', generate new UnaryPlusOp new PostIncrementOp new Int 0
eq '(+0)++', generate new PostIncrementOp new UnaryPlusOp new Int 0
eq 'new (F?)', generate new NewOp (new UnaryExistsOp new Identifier 'F'), []
eq '(new F)?', generate new UnaryExistsOp new NewOp (new Identifier 'F'), []


# binary operators
eq '0; 1', generate new SeqOp (new Int 0), new Int 1
eq '0 or 1', generate new LogicalOrOp (new Int 0), new Int 1
eq '0 and 1', generate new LogicalAndOp (new Int 0), new Int 1
eq '0 | 1', generate new BitOrOp (new Int 0), new Int 1
eq '0 ^ 1', generate new BitXorOp (new Int 0), new Int 1
eq '0 & 1', generate new BitAndOp (new Int 0), new Int 1
eq '0 is 1', generate new EQOp (new Int 0), new Int 1
eq '0 isnt 1', generate new NEQOp (new Int 0), new Int 1
eq '0 < 1', generate new LTOp (new Int 0), new Int 1
eq '0 <= 1', generate new LTEOp (new Int 0), new Int 1
eq '0 > 1', generate new GTOp (new Int 0), new Int 1
eq '0 >= 1', generate new GTEOp (new Int 0), new Int 1
eq '0 in 1', generate new InOp (new Int 0), new Int 1
eq '0 of 1', generate new OfOp (new Int 0), new Int 1
eq '0 instanceof 1', generate new InstanceofOp (new Int 0), new Int 1
eq '0 << 1', generate new LeftShiftOp (new Int 0), new Int 1
eq '0 >> 1', generate new SignedRightShiftOp (new Int 0), new Int 1
eq '0 >>> 1', generate new UnsignedRightShiftOp (new Int 0), new Int 1
eq '0 + 1', generate new PlusOp (new Int 0), new Int 1
eq '0 - 1', generate new SubtractOp (new Int 0), new Int 1
eq '0 * 1', generate new MultiplyOp (new Int 0), new Int 1
eq '0 / 1', generate new DivideOp (new Int 0), new Int 1
eq '0 % 1', generate new RemOp (new Int 0), new Int 1

# negated binary operators
eq '0 not in 1', generate new LogicalNotOp new InOp (new Int 0), new Int 1

# binary operators and function literals
eq '(->) % 0', generate new RemOp (new CSFunction [], new Block []), new Int 0
eq '0 % ->', generate new RemOp (new Int 0), new CSFunction [], new Block []
eq '->; 0', generate new SeqOp (new CSFunction [], new Block []), new Int 0
eq '0; ->', generate new SeqOp (new Int 0), new CSFunction [], new Block []

# binary operators and function application
eq 'f() % 0', generate new RemOp (new FunctionApplication (new Identifier "f"), []), new Int 0
eq '(f 0) % 1', generate new RemOp (new FunctionApplication (new Identifier 'f'), [new Int 0]), new Int 1
eq '0 % f 1', generate new RemOp (new Int 0), new FunctionApplication (new Identifier 'f'), [new Int 1]
eq 'f 0 % 1', generate new FunctionApplication (new Identifier 'f'), [new RemOp (new Int 0), new Int 1]

# binary operators and unary operators on functions
eq '(do ->) % 0', generate new RemOp (new DoOp new CSFunction [], new Block []), new Int 0


# member access operators
eq 'a.b', generate new MemberAccessOp (new Identifier 'a'), 'b'
eq 'a.b.c', generate new MemberAccessOp (new MemberAccessOp (new Identifier 'a'), 'b'), 'c'
eq 'fn()?.a', generate new SoakedMemberAccessOp (new FunctionApplication (new Identifier 'fn'), []), 'a'
eq '(fn 0)::a', generate new ProtoMemberAccessOp (new FunctionApplication (new Identifier 'fn'), [new Int 0]), 'a'
eq '(->)?::a', generate new SoakedProtoMemberAccessOp (new CSFunction [], new Block []), 'a'
eq '(-> 0).a', generate new MemberAccessOp (new CSFunction [], new Block [new Int 0]), 'a'
eq '(new A).b', generate new MemberAccessOp (new NewOp (new Identifier 'A'), []), 'b'
eq '(new A 0).b', generate new MemberAccessOp (new NewOp (new Identifier 'A'), [new Int 0]), 'b'

eq 'a[0]', generate new DynamicMemberAccessOp (new Identifier 'a'), new Int 0
eq 'a[0][1]', generate new DynamicMemberAccessOp (new DynamicMemberAccessOp (new Identifier 'a'), new Int 0), new Int 1
eq 'a?[\'b\']', generate new SoakedDynamicMemberAccessOp (new Identifier 'a'), new CSString 'b'
eq 'a::[c = 0]', generate new DynamicProtoMemberAccessOp (new Identifier 'a'), new AssignOp (new Identifier 'c'), new Int 0
eq 'a?::[0; 1]', generate new SoakedDynamicProtoMemberAccessOp (new Identifier 'a'), new SeqOp (new Int 0), new Int 1
eq 'fn()[0]', generate new DynamicMemberAccessOp (new FunctionApplication (new Identifier 'fn'), []), new Int 0
eq '(fn 0)[0]', generate new DynamicMemberAccessOp (new FunctionApplication (new Identifier 'fn'), [new Int 0]), new Int 0
eq '(->)[0]', generate new DynamicMemberAccessOp (new CSFunction [], new Block []), new Int 0
eq '(-> 0)[0]', generate new DynamicMemberAccessOp (new CSFunction [], new Block [new Int 0]), new Int 0
eq '(new A)[0]', generate new DynamicMemberAccessOp (new NewOp (new Identifier 'A'), []), new Int 0
eq '(new A 0)[1]', generate new DynamicMemberAccessOp (new NewOp (new Identifier 'A'), [new Int 0]), new Int 1

eq 'a.b[c]::d', generate new ProtoMemberAccessOp (new DynamicMemberAccessOp (new MemberAccessOp (new Identifier 'a'), 'b'), new Identifier 'c'), 'd'
