import {curry, binary, rtee, tee, flow} from "@pandastrike/garden"
import {base, template, parameters, method, accept, media, from,
  request, expect} from "@dashkite/mercury"
import accessors from "./accessors"
import discover from "./discover"

failure = (code, context) ->
  error = switch code
    when "method not allowed"
      new Error "Mercury Sky: method [#{context.method}]
        not allowed for [#{context.resource}]"
    else
      new Error "Mercury Sky: #{code}"

  # TODO if we add more errors, remember to add response/status
  error.context = context
  error

allowed = tee (context) ->
  if !(accessors.method context)?
    throw failure "method not allowed", context

Sky =

  discover: curry (url, context) ->
    context.api = await discover url
    base url, context

  resource: curry binary flow [
    rtee (value, context) -> context.resource = value
    from [
      accessors.template
      template
    ]
    parameters {}
  ]

  method: curry binary flow [
    method
    allowed
    from [
      accessors.accept
      accept
    ]
    from [
      accessors.media
      media
    ]
  ]

  request: flow [
    request
    expect.ok
    from [
      accessors.expect.status
      expect.status
    ]
    from [
      accessors.expect.media
      expect.media
    ]
    # TODO add combinators to verify headers
  ]

export default Sky
