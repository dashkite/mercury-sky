import {curry, rtee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {cast, use, url, method, accept, cache, request, json} from "./mercury"

accessors =
  template: ({api, resource}) -> property "template", api?[resource]
  method: _M = ({api, resource, method}) -> api[resource][method]
  signatures: _S = (context) -> property "signatures", _M context
  request: _Rq = (context) -> property "request", _S context
  response: _Rs = (context) -> property "response", _S context
  accept: (context) -> "application/json" if (property "schema", _Rs context)?
  media: (context) -> "application/json" if (property "schema", _Rq context)?
  expect:
    media: (context) -> "application/json" if (property "schema", _Rs context)?
    status: (context) -> property "status", _Rs context

builders =
  template: cast template, [ accessors.template ]
  accept: cast accept, [ accessors.accept ]
  media: cast media, [ accessors.media ]
  expect:
    media: cast expect.media, [ accessors.expect.media ]
    status: cast expect.status, [ accessors.expect.status ]

discover = flow [
  use Fetch mode: "cors"
  cast url, [ property "data" ]
  method "get"
  accept "application/json"
  cache [
    request
    json
    property "json"
  ]
]

Sky =

  discover: curry rtee (url, context) ->
    context.api = await discover url

  resource: curry rtee (value, context) ->
    context.resource = value
    builders.template context

  method: curry rtee (value, context) ->
    context.method = value
    builders.accept context
    builders.media context

  request: tee (context) ->
    request context
    builders.expect context
    builders.expect.media context
