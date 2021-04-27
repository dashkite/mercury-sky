import assert from "assert"
import {print, test, success} from "amen"

import * as _ from "@dashkite/joy"
# import "fake-indexeddb/auto"
import fetch from "node-fetch"
# import "./custom-event"
# import "./local-storage"
import faker from "faker"
# import Profile from "@dashkite/zinc"

import {
  Room
  Key
} from "./room"

globalThis.fetch ?= fetch
global.Request ?= fetch.Request

do ->

  # Profile.current = await Profile.create "http-test.dashkite.com",
  #   nickname: faker.internet.userName()

  print await test "Mercury Zinc: HTTP Combinators For Zinc",  [

    test
      description: "zinc test"
      wait: false
      ->
        console.log await Key.get "https://kiki-api.dashkite.com"
        # {room} = await Room.create
        #   title: titleCase faker.lorem.words()
        #   blurb: faker.lorem.sentence()
        # assert room.created
        #
        # await Room.patch
        #   title: titleCase faker.lorem.words()
        #   address: room.address
        #
        # messages = await Room.Messages.get
        #   address: room.address
        #   after: (new Date).toISOString()
        # assert Array.isArray messages
        #
        # assert.rejects (-> Room.Messages.put()), /not allowed/
  ]

  process.exit if success then 0 else 1
