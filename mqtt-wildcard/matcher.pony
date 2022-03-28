primitive MqttWildcardMatcher
  fun apply(
    tokens: Array[MqttToken val] val,
    pattern: MqttWildcardDfaState val)
  : Bool val =>
    var state: MqttWildcardDfaState val = pattern
    for token in tokens.values() do
      if state.consumable(token) then
        match state.outgoing()
        | let state': MqttWildcardDfaState val =>
          state = state'
        else
          return state.matched()
        end
      else
        return false
      end
    end
    state.matched()
