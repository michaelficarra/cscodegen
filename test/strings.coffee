suite 'Strings', ->

  test 'basic strings', ->
    eq "'string'", generate new CSString 'string'

  test 'quotes within strings', ->
    eq "'\\''", generate new CSString '\''
    eq "'\"'", generate new CSString '"'

  test 'special escape sequences', ->
    eq "'\\b'", generate new CSString '\b'
    eq "'\\u0001'", generate new CSString '\u0001'
    eq "'\\0'", generate new CSString '\0'
