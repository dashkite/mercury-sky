failure = do ({codes, message} = {}) ->

  codes =

    "unexpected status": ({expect, response}) ->
      "unexpected status: #{response.status}"

    "not ok": ({response}) ->
      "status is not ok: #{response.status}"

    "no current profile": ->
      "Profile.current is undefined"

    "unsupported media type": ({response})->
      "unsupported media type: #{response.headers['content-type']}"

  (code, context) ->
    message = codes[code] context
    new Error "Mercury: #{message}"

export default failure
