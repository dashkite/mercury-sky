import * as _ from "@dashkite/joy"
import * as m from "@dashkite/mercury"
# import Profile from "@dashkite/zinc"
# import Zinc from "@dashkite/mercury-zinc"

import * as $ from "../src/index"

# {discover, resource, method, request} = Sky
# {grants, claim, sigil} = Zinc

generateRoom = ({title, blurb, host}) ->
  profile = await Profile.current
  {address, publicKeys, data: {nickname}} = profile
  {title, blurb, host: nickname, address, publicKeys}

Key =

  get:
    _.flow [
      m.request [
        $.discover
        _.pipe [
          $.resource "public keys"
          $.method "get"
          m.parameters type: "encryption"
          # m.cache "test"

        ]
      ]
      m.response [ m.text ]
      _.get "text"
    ]

# Room =
#
#   create:
#
#     flow [
#       generateRoom
#       m.request _.flow [
#         $.discover "https://kiki-api.dashkite.com"
#         _.pipe [
#           $.resource "rooms"
#           $.method "post"
#           m.content
#           $.accept "text/plain"
#         ]
#         k.push sigil "kiki-api.dashkite.com"
#         m.authorize
#       ]
#       m.response [
#         m.json
#         k.push Key.get
#         z.grants "http-test.dashkite.com"
#       ]
#       _.get "json"
#     ]
#
#   patch:
#     flow [
#       initialize
#       resource "room"
#       method "patch"
#       from [
#         data [ "address" ]
#         parameters
#       ]
#       from [
#         data [ "title" ]
#         content
#       ]
#       from [
#         claim "http-test.dashkite.com"
#         authorize
#       ]
#       request
#     ]
#
#   Messages:
#
#     get:
#       flow [
#         initialize
#         resource "messages"
#         method "get"
#         from [
#           property "data"
#           parameters
#         ]
#         from [
#           claim "http-test.dashkite.com"
#           authorize
#         ]
#         request
#         json
#         property "json"
#       ]
#
#     # this should throw b/c put is not supported
#     put:
#       flow [
#         initialize
#         resource "messages"
#         method "put"
#       ]


export {
  Key
  # Room
}
