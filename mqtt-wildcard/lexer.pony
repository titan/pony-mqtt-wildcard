
primitive MqttLevelSeparator

primitive MqttMultiLevelWildcard

primitive MqttSingleLevelWildcard

primitive MqttTextToken

type MqttToken is (MqttLevelSeparator | MqttMultiLevelWildcard | MqttSingleLevelWildcard | (MqttTextToken, String val))

primitive MqttTokenStringable
  fun apply(x: MqttToken): String val =>
    match x
    | MqttLevelSeparator => "MqttLevelSeparator"
    | MqttMultiLevelWildcard => "MqttMultiLevelWildcard"
    | MqttSingleLevelWildcard => "MqttSingleLevelWildcard"
    | (MqttTextToken, let text: String val) => "(MqttTextToken, " + text + ")"
    end

primitive MqttTokenEquals
  fun apply(a: MqttToken, b: MqttToken): Bool val =>
    match a
    | MqttLevelSeparator =>
      match b
      | MqttLevelSeparator =>
        true
      else
        false
      end
    | MqttMultiLevelWildcard =>
      match b
      | MqttMultiLevelWildcard =>
        true
      else
        false
      end
    | MqttSingleLevelWildcard =>
      match b
      | MqttSingleLevelWildcard =>
        true
      else
        false
      end
    | (MqttTextToken, let a': String val) =>
      match b
      | (MqttTextToken, let b': String val) =>
        if a' == b' then
          true
        else
          false
        end
      else
        false
      end
    end

primitive _BeginState

primitive _TextState

type _WildcardLexerState is (_BeginState | _TextState)

primitive MqttWildcardLexDone

primitive MqttWildcardLexFailed

primitive MqttWildcardLexErrorTextTokenContainsPlus
  fun apply(): U8 val =>
    0x01

primitive MqttWildcardLexErrorTextTokenContainsSharp
  fun apply(): U8 val =>
    0x02

primitive MqttWildcardLexErrorSharpMustBeLastToken
  fun apply(): U8 =>
    0x03

type MqttWildcardLexError is (MqttWildcardLexErrorTextTokenContainsPlus | MqttWildcardLexErrorTextTokenContainsSharp | MqttWildcardLexErrorSharpMustBeLastToken)

primitive MqttWildcardLexErrorStringable
  fun apply(x: MqttWildcardLexError): String val =>
    match x
    | MqttWildcardLexErrorTextTokenContainsPlus => "MqttWildcardLexErrorTextTokenContainsPlus"
    | MqttWildcardLexErrorTextTokenContainsSharp => "MqttWildcardLexErrorTextTokenContainsSharp"
    | MqttWildcardLexErrorSharpMustBeLastToken => "MqttWildcardLexErrorSharpMustBeLastToken"
    end

type MqttWildcardLexResult is ((MqttWildcardLexDone, Array[MqttToken val] val) | (MqttWildcardLexFailed, MqttWildcardLexError))

primitive MqttWildcardLexer
  fun apply(src: String val): MqttWildcardLexResult =>
    var state: _WildcardLexerState = _BeginState
    let result: Array[MqttToken val] iso = recover iso Array[MqttToken val] end
    var buf: String iso = recover iso String end
    var found_sharp: Bool = false
    for chr in src.array().values() do
      if found_sharp then
        return (MqttWildcardLexFailed, MqttWildcardLexErrorSharpMustBeLastToken)
      end
      match state
      | _BeginState =>
        match chr
        | '/' =>
          result.push(MqttLevelSeparator)
        | '#' =>
          result.push(MqttMultiLevelWildcard)
          found_sharp = true
        | '+' =>
          result.push(MqttSingleLevelWildcard)
        else
          buf.push(chr)
          state = _TextState
        end
      | _TextState =>
        match chr
        | '/' =>
          let buf' = buf.clone()
          result.push((MqttTextToken, consume buf'))
          result.push(MqttLevelSeparator)
          buf.clear()
          state = _BeginState
        | '#' =>
          return (MqttWildcardLexFailed, MqttWildcardLexErrorTextTokenContainsSharp)
        | '+' =>
          return (MqttWildcardLexFailed, MqttWildcardLexErrorTextTokenContainsPlus)
        else
          buf.push(chr)
        end
      end
    end
    if buf.size() > 0 then
      if found_sharp then
        return (MqttWildcardLexFailed, MqttWildcardLexErrorSharpMustBeLastToken)
      end
      result.push((MqttTextToken, consume buf))
    end
    (MqttWildcardLexDone, consume result)
