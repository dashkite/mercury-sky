import assert from "assert"
import {print, test, success} from "amen"

import fetch from "node-fetch"

import {identity, tee, flow} from "panda-garden"
import {property} from "panda-parchment"
import Profile from "@dashkite/zinc"
import {cast} from "@dashkite/katana"
import {use, parameters, content, accept, authorize,
  cache, text, json, data, Fetch} from "@dashkite/mercury"
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
      cast content, [ property "data" ]
      method "post"
      cast authorize, [ sigil ]
      request
      json
      cast grants, [ Key.get ]
      property "json"
    ]

  Title:
    put:
      flow [
        initialize
        resource "title"
        method "put"
        cast parameters, [ data ({address}) -> {address} ]
        cast content, [ data ({title}) -> {title} ]
        cast authorize, [ claim ]
        request
      ]

  Messages:
    get:
      flow [
        initialize
        resource "messages"
        method "get"
        cast parameters, [ property "data" ]
        cast authorize, [ claim ]
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
