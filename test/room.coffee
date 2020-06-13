import assert from "assert"
import {print, test, success} from "amen"

import fetch from "node-fetch"

import {identity, tee, flow} from "panda-garden"
import property from "../src/property"
import Profile from "@dashkite/zinc"
import {use, parameters, content, accept, from, data, authorize,
  cache, text, json, Fetch} from "@dashkite/mercury"
import Zinc from "@dashkite/mercury-zinc"

import Sky from "../src/index"

global.fetch = fetch

{convert, randomBytes} = Profile.Confidential

{discover, resource, method, request} = Sky
{grants, claim, sigil} = Zinc

generateAddress = ->
  convert
    from: "bytes"
    to: "safe-base64"
    await randomBytes 16

generateRoom = ({title, blurb, host}) ->
  profile = await Profile.current
  {publicKeys, data: {nickname}} = profile
  address = await generateAddress()
  {title, blurb, host: nickname, address, publicKeys}

initialize =

  flow [
    use Fetch.client mode: "cors"
    discover "https://http-test.dashkite.com"
    # discover "https://storm-api.dashkite.com"
  ]

Key =

  get:
    flow [
      initialize
      resource "public encryption key"
      method "get"
      accept "text/plain"
      cache flow [
        request
        text
        property "text"
      ]
    ]

Room =

  create:

    flow [
      generateRoom
      initialize
      resource "rooms"
      from [
        property "data"
        content
      ]
      method "post"
      from [
        sigil
        authorize
      ]
      request
      json
      from [
        Key.get
        grants
      ]
      property "json"
    ]

  patch:
    flow [
      initialize
      resource "room"
      method "patch"
      from [
        data [ "address" ]
        parameters
      ]
      from [
        data [ "title" ]
        content
      ]
      from [
        claim
        authorize
      ]
      request
    ]

  Messages:

    get:
      flow [
        initialize
        resource "messages"
        method "get"
        from [
          property "data"
          parameters
        ]
        from [
          claim
          authorize
        ]
        request
        json
        property "json"
      ]

    # this should throw b/c put is not supported
    put:
      flow [
        initialize
        resource "messages"
        method "put"
      ]


export default Room
