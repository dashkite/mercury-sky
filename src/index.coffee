import {curry, binary, spread, tee, rtee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {cast, use, url, base, template, parameters, method, accept, media,
  cache, request, expect, json, Fetch} from "./mercury"

accessors =
  resources: _Rx = ({api, resource}) -> property "resources", api
  resource: _R = (context) -> property context.resource, _Rx context
  template: (context) -> property "template", _R context
  methods: _Mx = (context) -> property "methods", _R context
  method: _M = (context) -> property context.method, _Mx context
  signatures: _S = (context) -> property "signatures", _M context
  request: _Rq = (context) -> property "request", _S context
  response: _Rs = (context) -> property "response", _S context
  accept: (context) -> "application/json" if (property "schema", _Rs context)?
  media: (context) -> "application/json" if (property "schema", _Rq context)?
  expect:
    media: (context) -> "application/json" if (property "schema", _Rs context)?
    status: (context) -> property "status", _Rs context

discover = flow [
  use Fetch.client mode: "cors"
  cast url, [ property "data" ]
  method "get"
  accept "application/json"
  cache flow [
    request
    json
    property "json"
  ]
]

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
