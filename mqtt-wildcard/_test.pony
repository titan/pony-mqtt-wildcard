use "pony_test"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestWildcardLexer)
    test(_TestWildcardCompiler)
    test(_TestWildcardMatcher)
