failure = do ({codes, message} = {}) ->

  codes =

    "unexpected status": ({expect, response}) ->
      "unexpected status: #{response.status}"

    "not ok": ({response}) ->
      "status is not okay: #{response.status}"

    "no current profile": ->
      "Profile.current is undefined"

  (code, context) ->
    message = codes[code] context
    new Error "Mercury: #{message}"

export default failure
