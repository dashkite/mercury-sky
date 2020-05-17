import {flow} from "panda-garden"
import {property} from "panda-parchment"
import {cast, use, url, method, accept,
  cache, request, json, Fetch} from "./mercury"

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

export default discover
