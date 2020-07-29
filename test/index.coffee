import "source-map-support/register"
import assert from "assert"
import {print, test, success} from "amen"

import "fake-indexeddb/auto"
import fetch from "node-fetch"
import "./custom-event"
import "./local-storage"

import faker from "faker"
import {flow} from "panda-garden"
import {titleCase, property} from "panda-parchment"
import Profile from "@dashkite/zinc"

import Room from "./room"

global.fetch = fetch

do ->

  Profile.current = await Profile.create "http-test.dashkite.com",
    nickname: faker.internet.userName()

  print await test "Mercury: HTTP Combinators",  [

    test
      description: "sky test"
      wait: false
      ->
        {room} = await Room.create
          title: titleCase faker.lorem.words()
          blurb: faker.lorem.sentence()
        assert room.created

        await Room.patch
          title: titleCase faker.lorem.words()
          address: room.address

        messages = await Room.Messages.get
          address: room.address
          after: (new Date).toISOString()
        assert Array.isArray messages

        assert.rejects (-> Room.Messages.put()), /not allowed/
  ]

  process.exit if success then 0 else 1
