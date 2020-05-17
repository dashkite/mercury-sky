import URLTemplate from "url-template"
import {curry, tee, rtee, flow} from "panda-garden"
import {stack, push, pop} from "@dashkite/katana"
import {last, isString} from "panda-parchment"
import Profile from "@dashkite/zinc"
import failure from "./failure"

{sign, hash, Message} = Profile.Confidential

# TODO why isn't this in parchment?
reverse = (ax) -> ax.reverse()

cast = (g, fx) -> stack flow [ (push f for f in reverse fx)..., (pop g), last ]

use = curry (client, data) ->
  if client.run? then client.run {data} else {client, data}

url = curry rtee (value, context) -> context.url = new URL value

base = curry rtee (value, context) -> context.base = value

path = curry rtee (value, context) ->
  context.path = value
  context.url = new URL value, context.base

query = curry rtee (object, context) ->
  for key, value of object
    context.url.searchParams.append key, value

template = curry rtee (value, context) ->
  context.template = URLTemplate.parse value

parameters = curry rtee (object, context) ->
  context.parameters = object
  path (context.template.expand object), context

content = curry rtee (value, context) ->
  # TODO support streams and other content types
  #      this may also affect other combinators like Zinc.sigil
  context.body = if isString value then value else JSON.stringify value

headers = curry rtee (object, context) -> context.headers = object

accept = curry rtee (value, context) ->
  if value?
    (context.headers ?= {}).accept = value

media = curry rtee (value, context) ->
  if value?
    (context.headers ?= {})["content-type"] = value

method = curry rtee (value, context) -> context.method = value

authorize = curry rtee (value, context) ->
  (context.headers ?= {}).authorization = value

cache = do (cache = {}, {method, url, cached} = {}) ->
  curry (requestor, context) ->
    {url, method} = context
    if (cached = cache[url]?[method])?
      await cached
    else
      (cache[url] ?= {})[method] = requestor context

request = tee (context) -> context.response = await context.client context

expect =

  status: curry rtee (codes, context) ->
    if codes?
      if ! context.response.status in codes
        throw failure "unexpected status", context

  media:  curry rtee (value, context) ->
    if value?
      if ! ((context.response.headers.get "content-type") == value)
        throw failure "unsupported media type", context

  ok: (context) ->
    if !context.response.ok
      console.log context
      throw failure "not ok", context

text = tee (context) -> context.text = await context.response.text()

json = tee (context) -> context.json = await context.response.json()

blob = tee (context) -> context.blob = await context.response.blob()

data = curry (builder, context) -> await builder context.data

Fetch =

  client: do ({type, credentials} = {}) ->
    curry ({mode}, {url, method, headers, body}) ->
      fetch url, {method, headers, body,  mode}

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

export {cast, use, url, base, path,
  query, template, parameters, content, headers,
  accept, media, method, authorize, cache, request, expect,
  text, json, blob,
  data, Fetch, Zinc}
