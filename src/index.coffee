import {curry, binary, rtee, flow} from "panda-garden"
import {cast, base, template, parameters, method, accept, media,
  request, expect} from "./mercury"
import accessors from "./accessors"
import discover from "./discover"

Sky =

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
    cast accept, [ accessors.accept ]
    cast media, [ accessors.media ]
  ]

  request: flow [
    request
    expect.ok
    cast expect.status, [ accessors.expect.status ]
    cast expect.media, [ accessors.expect.media ]
  ]

export default Sky
