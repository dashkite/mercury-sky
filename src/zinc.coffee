import URLTemplate from "url-template"
import {curry, rtee} from "panda-garden"
import {last, isString} from "panda-parchment"
import Profile from "@dashkite/zinc"
import failure from "./failure"

{sign, hash, Message} = Profile.Confidential

Zinc =

  grants: do ({profile} = {}) ->
    curry rtee (key, context) ->
      profile = await Profile.current
      throw failure "no current profile" if !profile?
      profile.receive key, context.json.directory

  claim: do ({profile, path, claim} = {}) ->
    ({url, parameters, method}) ->
      profile = await Profile.current
      throw failure "no current profile" if !profile?
      # TODO consider another term for path
      path = url.pathname + url.search
      if (token = profile.exercise {path, parameters, method})?
        "X-Capability #{token}"
      else
        console.warn "Mercury: Zinc: claim:
          no matching grant for [#{method} #{path}]"

  sigil: do ({profile, declaration} = {}) ->
    ({url, method, body}) ->
      profile = await Profile.current
      throw failure "no current profile" if !profile?
      declaration = sign profile.keyPairs.signature,
        Message.from "utf8",
          JSON.stringify
            method: method.toUpperCase()
            path: url.pathname + url.search
            date: new Date().toISOString()
            hash: (hash Message.from "utf8", body).to "base64"
      token = declaration.to "base64"
      "Sigil #{token}"

export default Zinc
