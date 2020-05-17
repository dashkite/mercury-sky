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

  Profile.current = await Profile.create
    nickname: faker.internet.userName()

  print await test "Mercury: HTTP Combinators",  [

    test
      description: "sky test"
      wait: false
      ->
        console.log "create room ..."
        {room} = await Room.create
          title: titleCase faker.lorem.words()
          blurb: faker.lorem.sentence()
        assert room.created
        console.log "... room created"

        console.log "set title ..."
        await Room.Title.put
          title: titleCase faker.lorem.words()
          address: room.address
        console.log "... title set"

        console.log "get messages ..."
        messages = await Room.Messages.get
          address: room.address
          after: (new Date).toISOString()
        assert Array.isArray messages
        console.log "... got messages."

  ]
