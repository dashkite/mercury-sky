import * as _ from "@dashkite/joy"
import * as m from "@dashkite/mercury"
import * as k from "@dashkite/katana"
import * as ks from "@dashkite/katana/sync"

# TODO this pattern keeps coming up...
setter =
  async: (f) ->
    (value) ->
      if k.isDaisho value
        ((ks.test _.isDefined, f) value)
      else
        k.assign _.flow [
          k.push -> value
          f
        ]

  sync: (f) ->
    (value) ->
      if k.isDaisho value
        ((ks.test _.isDefined, f) value)
      else
        ks.assign _.pipe [
          ks.push -> value
          f
        ]

discover = _.flow [
  m.request [
    m.url
    m.method "get"
    m.accept "application/json"
    # m.cache "discover"
    m.expect.ok
  ]
  m.response [ m.json ]
  _.get "json"
]

# TODO use the error / messages code from atlas?

messages =
  "method not allowed":
    _.template "method {{method}} not allowed for {{format}}"

failure = _.curry (key, context) ->
  Object.assign (new Error "mercury sky:
    #{_.apply (messages[key] ? key) [ context ]}"),
    context: context
    response: context.response
    status: context.response?.status

export {
  setter
  discover
  failure
}
