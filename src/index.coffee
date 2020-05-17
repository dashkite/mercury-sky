import {curry, binary, rtee, flow} from "panda-garden"
import {base, template, parameters, method, accept, media,
  request, expect} from "@dashkite/mercury"
import {cast} from "@dashkite/katana"
import accessors from "./accessors"
import discover from "./discover"

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
