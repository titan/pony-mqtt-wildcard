use "pony_test"

class _TestWildcardCompiler is UnitTest
  fun name(): String => "WildcardCompiler"

  fun apply(h: TestHelper) =>
    _test(
      h,
      [MqttMultiLevelWildcard],
      MqttWildcardDfaState(
        MqttWildcardDfaStart,
        None,
        MqttWildcardDfaState(MqttWildcardDfaMatch)))
    _test(
      h,
      [MqttSingleLevelWildcard],
      MqttWildcardDfaState(
        MqttWildcardDfaStart,
        None,
        MqttWildcardDfaState(MqttWildcardDfaMatch)))
    _test(
      h,
      [
        MqttSingleLevelWildcard
        MqttLevelSeparator
        MqttSingleLevelWildcard
      ],
      MqttWildcardDfaState(
        MqttWildcardDfaStart,
        None,
        MqttWildcardDfaState(
          MqttWildcardDfaNormal,
          MqttLevelSeparator,
          MqttWildcardDfaState(
            MqttWildcardDfaNormal,
            None,
            MqttWildcardDfaState(MqttWildcardDfaMatch)))))
    _test(
      h,
      [
        (MqttTextToken, "foo")
        MqttLevelSeparator
        MqttSingleLevelWildcard
      ],
      MqttWildcardDfaState(
        MqttWildcardDfaStart,
        (MqttTextToken, "foo"),
        MqttWildcardDfaState(
          MqttWildcardDfaNormal,
          MqttLevelSeparator,
          MqttWildcardDfaState(
            MqttWildcardDfaNormal,
            None,
            MqttWildcardDfaState(MqttWildcardDfaMatch)))))
    _test(
      h,
      [
        (MqttTextToken, "foo")
        MqttLevelSeparator
        (MqttTextToken, "bar")
      ],
      MqttWildcardDfaState(
        MqttWildcardDfaStart,
        (MqttTextToken, "foo"),
        MqttWildcardDfaState(
          MqttWildcardDfaNormal,
          MqttLevelSeparator,
          MqttWildcardDfaState(
            MqttWildcardDfaNormal,
            (MqttTextToken, "bar"),
            MqttWildcardDfaState(MqttWildcardDfaMatch)))))

  fun _test(h: TestHelper, tokens: Array[MqttToken val] val, state: MqttWildcardDfaState val, loc: SourceLoc = __loc) =>
    match MqttWildcardCompiler(tokens)
    | (MqttWildcardCompileDone, let state': MqttWildcardDfaState val) =>
      h.assert_eq[MqttWildcardDfaState val](state', state)
    | (MqttWildcardCompileFailed, let err: String val) =>
      h.fail(_format_loc(loc) + err)
    end

  fun _format_loc(loc: SourceLoc): String =>
    loc.file() + ":" + loc.line().string() + ": "
