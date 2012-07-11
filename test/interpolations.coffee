suite 'Interpolations', ->

  setup ->
    for letter in ['a', 'b']
      @["str#{letter.toUpperCase()}"] = new CSString letter
      @["var#{letter.toUpperCase()}"] = new Identifier letter

  test 'simple interpolations', ->
    eq '"ab"'          , generate new ConcatOp @strA, @strB
    eq '"a#{b}"'       , generate new ConcatOp @strA, @varB
    eq '"#{a}b"'       , generate new ConcatOp @varA, @strB
    eq '"#{a}#{b}"'    , generate new ConcatOp @varA, @varB
    eq '"aab"'         , generate new ConcatOp @strA, new ConcatOp (@strA), @strB
    eq '"#{a}ab"'      , generate new ConcatOp @varA, new ConcatOp (@strA), @strB
    eq '"a#{a}b"'      , generate new ConcatOp @strA, new ConcatOp (@varA), @strB
    eq '"aa#{b}"'      , generate new ConcatOp @strA, new ConcatOp (@strA), @varB
    eq '"#{a}#{a}b"'   , generate new ConcatOp @varA, new ConcatOp (@varA), @strB
    eq '"#{a}a#{b}"'   , generate new ConcatOp @varA, new ConcatOp (@strA), @varB
    eq '"a#{a}#{b}"'   , generate new ConcatOp @strA, new ConcatOp (@varA), @varB
    eq '"#{a}#{a}#{b}"', generate new ConcatOp @varA, new ConcatOp (@varA), @varB
