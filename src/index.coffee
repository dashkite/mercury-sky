import {curry, tee, rtee, flow} from "panda-garden"
import {property} from "panda-parchment"
import {cast, use, url, base, template,parameters, method, accept, media,
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


builders =
  template: cast template, [ accessors.template ]
  accept: cast accept, [ accessors.accept ]
  media: cast media, [ accessors.media ]
  expect:
    media: cast expect.media, [ accessors.expect.media ]
    status: cast expect.status, [ accessors.expect.status ]

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

  discover: curry rtee (url, context) ->
    context.api = await discover url
    base url, context

  resource: curry rtee (value, context) ->
    context.resource = value
    await builders.template context
    # default the URL based on empty parameters
    parameters {}, context

  method: curry rtee (value, context) ->
    context.method = value
    await builders.accept context
    builders.media context

  # TODO check for expected headers
  #      see: https://github.com/
  #           pandastrike/panda-sky-client/
  #           blob/master/src/method.coffee#L33-L47
  #
  # TODO validate/correct auth header? or allow auth property?

  request: tee (context) ->
    await request context
    await builders.expect.status context
    await expect.ok context
    builders.expect.media context

export default Sky
