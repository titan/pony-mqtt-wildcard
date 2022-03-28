use "pony_test"

class _TestWildcardMatcher is UnitTest
  fun name(): String => "WildcardMatcher"

  fun apply(h: TestHelper) =>
    _test(
      h,
      [
        (MqttTextToken, "foo")
        MqttLevelSeparator
        (MqttTextToken, "bar")
      ],
      MqttWildcardDfaState(
        MqttWildcardDfaStart,
        None,
        MqttWildcardDfaState(MqttWildcardDfaMatch)
      ),
      true
    )
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
            None,
            MqttWildcardDfaState(MqttWildcardDfaMatch)
          )
        )
      ),
      true
    )
    _test(
      h,
      [
        (MqttTextToken, "foo")
        MqttLevelSeparator
        (MqttTextToken, "bar")
      ],
      MqttWildcardDfaState(
        MqttWildcardDfaStart,
        None,
        MqttWildcardDfaState(
          MqttWildcardDfaNormal,
          MqttLevelSeparator,
          MqttWildcardDfaState(
            MqttWildcardDfaNormal,
            (MqttTextToken, "bar"),
            MqttWildcardDfaState(MqttWildcardDfaMatch)
          )
        )
      ),
      true
    )
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
            MqttWildcardDfaState(MqttWildcardDfaMatch)
          )
        )
      ),
      true
    )
    _test(
      h,
      [
        (MqttTextToken, "foo")
        MqttLevelSeparator
        (MqttTextToken, "bar")
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
            MqttWildcardDfaState(MqttWildcardDfaMatch)
          )
        )
      ),
      true
    )
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
            (MqttTextToken, "foo"),
            MqttWildcardDfaState(MqttWildcardDfaMatch)
          )
        )
      ),
      false
    )

  fun _test(h: TestHelper, tokens: Array[MqttToken val] val, state: MqttWildcardDfaState val, expect: Bool val, loc: SourceLoc = __loc)  =>
    h.assert_eq[Bool](MqttWildcardMatcher(tokens, state), expect)
