primitive MqttWildcardDfaStart

primitive MqttWildcardDfaNormal

primitive MqttWildcardDfaMatch

type MqttWildcardDfaStateType is (MqttWildcardDfaStart | MqttWildcardDfaNormal | MqttWildcardDfaMatch)

class MqttWildcardDfaState
  let _type: MqttWildcardDfaStateType val
  let _consume: (MqttToken val | None)
  let _outgoing: (MqttWildcardDfaState val | None)
  new iso create(
    type': MqttWildcardDfaStateType val,
    consume': (MqttToken val | None) = None,
    outgoing': (MqttWildcardDfaState val | None) = None)
  =>
    _type = type'
    _consume = consume'
    _outgoing = outgoing'

  fun box consumable(token: MqttToken): Bool =>
    match _consume
    | let token': MqttToken =>
      MqttTokenEquals(token', token)
    else
      true
    end

  fun box outgoing(): (MqttWildcardDfaState val | None) =>
    _outgoing

  fun box matched(): Bool =>
    match _type
    | MqttWildcardDfaMatch =>
      true
    else
      false
    end

  fun box eq(that: box->MqttWildcardDfaState): Bool val =>
    match _type
    | MqttWildcardDfaStart =>
      match that._type
      | MqttWildcardDfaNormal =>
        return false
      | MqttWildcardDfaMatch =>
        return false
      end
    | MqttWildcardDfaNormal =>
      match that._type
      | MqttWildcardDfaStart =>
        return false
      | MqttWildcardDfaMatch =>
        return false
      end
    | MqttWildcardDfaMatch =>
      match that._type
      | MqttWildcardDfaStart =>
        return false
      | MqttWildcardDfaNormal =>
        return false
      end
    end

    match _consume
    | let token: MqttToken val =>
      match that._consume
      | let token': MqttToken val =>
        if not MqttTokenEquals(token, token') then
          return false
        end
      else
        return false
      end
    else
      match that._consume
      | let token': MqttToken val =>
        return false
      end
    end

    match _outgoing
    | let state: MqttWildcardDfaState val =>
      match that._outgoing
      | let state': MqttWildcardDfaState val =>
        state == state'
      else
        false
      end
    else
      match that._outgoing
      | let state': MqttWildcardDfaState val =>
        false
      else
        true
      end
    end

  fun box ne(that: box->MqttWildcardDfaState): Bool val =>
    not eq(that)

  fun box string(): String iso^ =>
    let typestr: String =
      match _type
      | MqttWildcardDfaStart => "MqttWildcardDfaStart"
      | MqttWildcardDfaNormal => "MqttWildcardDfaNormal"
      | MqttWildcardDfaMatch => "MqttWildcardDfaMatch"
      end

    let consumestr: String =
      match _consume
      | let token: MqttToken val =>
        MqttTokenStringable(token)
      else
        "None"
      end

    let outgoingstr: String =
      match _outgoing
      | let outgoing': MqttWildcardDfaState val =>
        outgoing'.string()
      else
        "None"
      end
    "(" + typestr + ", " + consumestr + ", " + outgoingstr + ")"

primitive MqttWildcardCompileDone

primitive MqttWildcardCompileFailed

type MqttWildcardCompileResult is ((MqttWildcardCompileDone, MqttWildcardDfaState val) | (MqttWildcardCompileFailed, String val))

primitive MqttWildcardCompiler
  fun apply(tokens: Array[MqttToken val] val): MqttWildcardCompileResult =>
    var state: MqttWildcardDfaState val = recover MqttWildcardDfaState(MqttWildcardDfaMatch) end
    match tokens.size()
    | 0 =>
      (MqttWildcardCompileFailed, "Tokens is empty")
    | 1 =>
      try
        match tokens(0) ?
        | MqttLevelSeparator =>
          state = MqttWildcardDfaState(MqttWildcardDfaStart, tokens(0) ?, state)
        | MqttMultiLevelWildcard =>
          state = MqttWildcardDfaState(MqttWildcardDfaStart, None, state)
        | MqttSingleLevelWildcard =>
          state = MqttWildcardDfaState(MqttWildcardDfaStart, None, state)
        | (MqttTextToken, _) =>
          state = MqttWildcardDfaState(MqttWildcardDfaStart, tokens(0) ?, state)
        end
        (MqttWildcardCompileDone, state)
      else
        (MqttWildcardCompileFailed, "Tokens is empty")
      end
    else
      let tokens': Array[MqttToken val] = tokens.slice(1).reverse()
      for token in tokens'.values() do
        match token
        | MqttLevelSeparator =>
          state = MqttWildcardDfaState(MqttWildcardDfaNormal, token, state)
        | MqttMultiLevelWildcard =>
          state = MqttWildcardDfaState(MqttWildcardDfaNormal, None, recover MqttWildcardDfaState(MqttWildcardDfaMatch) end)
        | MqttSingleLevelWildcard =>
          state = MqttWildcardDfaState(MqttWildcardDfaNormal, None, state)
        | (MqttTextToken, _) =>
          state = MqttWildcardDfaState(MqttWildcardDfaNormal, token, state)
        end
      end
      try
        match tokens(0) ?
        | MqttLevelSeparator =>
          state = MqttWildcardDfaState(MqttWildcardDfaStart, MqttLevelSeparator, state)
        | MqttMultiLevelWildcard =>
          return (MqttWildcardCompileFailed, "# must be the last charactor")
        | MqttSingleLevelWildcard =>
          state = MqttWildcardDfaState(MqttWildcardDfaStart, None, state)
        else
          state = MqttWildcardDfaState(MqttWildcardDfaStart, tokens(0) ?, state)
        end
        (MqttWildcardCompileDone, state)
      else
        (MqttWildcardCompileFailed, "Unknown error")
      end
    end
