import * as _ from "@dashkite/joy"
import * as k from "@dashkite/katana/sync"

resource = _.pipe [
  k.read "api"
  k.poke _.get "resources"
  k.read "resource"
  k.mpoke _.get
]

template = _.pipe [ resource, k.poke _.get "template" ]

methods = _.pipe [ resource, k.poke _.get "methods" ]

method = _.pipe [
  methods
  k.read "method"
  k.poke _.toLowerCase
  k.poke _.get
]

signatures = _.pipe [ method, k.poke _.get "signatures" ]

request = _.pipe [ signatures, k.poke _.get "request" ]

response = _.pipe [ signatures, k.poke _.get "response" ]

accept = _.pipe [
  response
  k.poke _.get "mediatype"
  k.test _.isDefined, _.pipe [
    k.poke _.join ","
    k.poke (type) -> type ? "application/json"
  ]
]

media = _.pipe [
  request
  k.poke _.get "mediatype"
  k.test _.isDefined, _.pipe [
    k.poke _.join ","
    k.poke (type) -> type ? "application/json"
  ]
]

status = _.pipe [ response, k.poke _.get "status" ]

export {
  resource
  template
  methods
  method
  signatures
  request
  response
  accept
  media
  status
}
