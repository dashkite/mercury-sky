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

{discover, resource, method, request} = Sky
{grants, claim, sigil} = Zinc

generateRoom = ({title, blurb, host}) ->
  profile = await Profile.current
  {address, publicKeys, data: {nickname}} = profile
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
        sigil "http-test.dashkite.com"
        authorize
      ]
      request
      json
      from [
        Key.get
        grants "http-test.dashkite.com"
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
        claim "http-test.dashkite.com"
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
          claim "http-test.dashkite.com"
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
