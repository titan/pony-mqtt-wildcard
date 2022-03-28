use "itertools"
use "pony_test"

class _TestWildcardLexer is UnitTest
  fun name(): String => "WildcardLexer"

  fun apply(h: TestHelper) =>
    _test(h, "#", [MqttMultiLevelWildcard])
    _test(
      h,
      "foo/bar",
      [
        (MqttTextToken, "foo")
        MqttLevelSeparator
        (MqttTextToken, "bar")
      ])
    _test(
      h,
      "/foo/bar",
      [
        MqttLevelSeparator
        (MqttTextToken, "foo")
        MqttLevelSeparator
        (MqttTextToken, "bar")
      ])
    _test(
      h,
      "/foo/+/bar",
      [
        MqttLevelSeparator
        (MqttTextToken, "foo")
        MqttLevelSeparator
        MqttSingleLevelWildcard
        MqttLevelSeparator
        (MqttTextToken, "bar")
      ])
    _test(
      h,
      "/foo/+/bar/#",
      [
        MqttLevelSeparator
        (MqttTextToken, "foo")
        MqttLevelSeparator
        MqttSingleLevelWildcard
        MqttLevelSeparator
        (MqttTextToken, "bar")
        MqttLevelSeparator
        MqttMultiLevelWildcard
      ])
    _test_error(h, "/foo+", MqttWildcardLexErrorTextTokenContainsPlus)
    _test_error(h, "/foo#", MqttWildcardLexErrorTextTokenContainsSharp)
    _test_error(h, "/foo/#/bar", MqttWildcardLexErrorSharpMustBeLastToken)

  fun _test(h: TestHelper, src: String val, expect: Array[MqttToken val] val, loc: SourceLoc = __loc) =>
    match MqttWildcardLexer(src)
    | (MqttWildcardLexDone, let actual: Array[MqttToken val] val) =>
      h.assert_eq[USize](actual.size(), expect.size())
      var ok: Bool = true
      try
        var i: USize = 0
        while i < expect.size() do
          if not MqttTokenEquals(expect(i) ?, actual(i) ?) then
            ok = false
            break
          end
          i = i + 1
        end
      else
        ok = false
      end

      if not ok then
        h.fail(_format_loc(loc) + "Assert EQ failed. Expected (" + _print_token_array(expect) + ") == (" + _print_token_array(actual) + ")")
      end
    | (MqttWildcardLexFailed, let err: MqttWildcardLexError) =>
      match err
      | MqttWildcardLexErrorTextTokenContainsPlus =>
        h.fail(_format_loc(loc) + "WildcardLex error: text token cannot contains +")
      | MqttWildcardLexErrorTextTokenContainsSharp =>
        h.fail(_format_loc(loc) + "WildcardLex error: text token cannot contains #")
      | MqttWildcardLexErrorSharpMustBeLastToken =>
        h.fail(_format_loc(loc) + "WildcardLex error: # must be the last token")
      end
    end

  fun _format_loc(loc: SourceLoc): String =>
    loc.file() + ":" + loc.line().string() + ": "

  fun _print_token_array(array: ReadSeq[MqttToken]): String =>
    "[len=" + array.size().string() + ": " + ", ".join(Iter[MqttToken](array.values()).map[String]({(x: MqttToken):  String => MqttTokenStringable(x)})) + "]"

  fun _test_error(h: TestHelper, src: String val, expect: MqttWildcardLexError, loc: SourceLoc = __loc) =>
    match MqttWildcardLexer(src)
    | (MqttWildcardLexFailed, let err: MqttWildcardLexError) =>
      if err() != expect() then
        h.fail(_format_loc(loc) + "Expect " + MqttWildcardLexErrorStringable(expect) + " but got " + MqttWildcardLexErrorStringable(err))
      end
    | (MqttWildcardLexDone, _) =>
      h.fail(_format_loc(loc) + "Expect MqttWildcardLexError(" + MqttWildcardLexErrorStringable(expect) + ") but it's not")
    end
