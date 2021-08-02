import * as _ from "@dashkite/joy"
import * as m from "@dashkite/mercury"
import * as k from "@dashkite/katana"
import * as ks from "@dashkite/katana/sync"
import * as a from "./accessors"

import {
  setter
  discover as _discover
  failure
} from "./helpers"

discover = setter.async k.assign _.flow [
  m.base
  k.push _discover
  k.write "api"
]

resource = setter.sync ks.assign _.pipe [
  ks.write "resource"
  a.template
  m.template
]

method = setter.sync ks.assign _.pipe [

  m.method

  a.methods

  ks.poke _.keys
  ks.test (_.negate _.includes), _.pipe [
    k.context
    k.peek failure "method not allowed"
  ]


  a.accept
  ks.test _.isDefined, _.pipe [
    m.accept
    m.expect.media
  ]

  a.media
  m.media

  a.status
  m.expect.status

  # TODO add combinators to verify headers

]

export {
  discover
  resource
  method
}
