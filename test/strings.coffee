suite 'Strings', ->

  test 'basic strings', ->
    eq "'string'", generate new CSString 'string'

  test 'quotes within strings', ->
    eq "'\\''", generate new CSString '\''
    eq "'\"'", generate new CSString '"'

  test 'special escape sequences', ->
    eq "'\\0'", generate new CSString '\0'
    eq "'\\b'", generate new CSString '\b'
    eq "'\\t'", generate new CSString '\t'
    eq "'\\n'", generate new CSString '\n'
    eq "'\\f'", generate new CSString '\f'
    eq "'\\r'", generate new CSString '\r'
    eq "'\\\\'", generate new CSString '\\'
    eq "'\\u0001'", generate new CSString '\u0001'
