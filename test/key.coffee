import * as _ from "@dashkite/joy"
import * as m from "@dashkite/mercury"
import * as k from "@dashkite/katana"
import * as $ from "../src/index"

Key =

  get: m.start [
    $.discover
    _.pipe [
      $.resource "public keys"
      $.method "get"
      m.parameters type: "encryption"
      # m.cache "test"
    ]
    m.request
    m.text
    k.get
  ]

export {
  Key
}
