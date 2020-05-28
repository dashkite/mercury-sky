import {flow} from "panda-garden"
import property from "./property"
import {use, url, method, accept,
  cache, request, json, Fetch} from "@dashkite/mercury"
import {cast} from "@dashkite/katana"

discover = flow [
  use Fetch.client mode: "cors"
  cast url, [ property "data" ]
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
