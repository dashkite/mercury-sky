import assert from "assert"
import {print, test, success} from "amen"

import * as _ from "@dashkite/joy"
import fetch from "node-fetch"

import {
  Key
} from "./key"

globalThis.fetch ?= fetch
global.Request ?= fetch.Request

do ->

  print await test "Mercury Zinc: HTTP Combinators For Sky",  [

    test
      description: "get key"
      wait: false
      ->
        assert.equal true,
          _.isString await Key.get "https://kiki-api.dashkite.com"
  ]

  process.exit if success then 0 else 1
