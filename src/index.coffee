import {curry, binary, rtee, tee, flow} from "panda-garden"
import {base, template, parameters, method, accept, media,
  request, expect} from "@dashkite/mercury"
import {cast} from "@dashkite/katana"
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

  cast: cast

  discover: curry (url, context) ->
    context.api = await discover url
    base url, context

  resource: curry binary flow [
    rtee (value, context) -> context.resource = value
    cast template, [ accessors.template ]
    parameters {}
  ]

  method: curry binary flow [
    method
    allowed
    cast accept, [ accessors.accept ]
    cast media, [ accessors.media ]
  ]

  request: flow [
    request
    expect.ok
    cast expect.status, [ accessors.expect.status ]
    cast expect.media, [ accessors.expect.media ]
    # TODO add combinators to verify headers
  ]

export default Sky
