import {flow} from "@dashkite/joy/function"
import property from "./property"
import {use, url, method, accept,
  cache, from, request, json, Fetch} from "@dashkite/mercury"

discover = flow [
  use Fetch.client mode: "cors"
  from [
    property "data"
    url
  ]
  method "get"
  accept "application/json"
  cache flow [
    request
    json
    property "json"
    property "resources"
  ]
]

export default discover
