import URLTemplate from "url-template"
import {curry, tee, rtee, flow} from "panda-garden"
import {stack, push, pop} from "@dashkite/katana"
import {reverse, last} from "panda-parchment"
import Events from "./events"
import failure from "./failure"

cast = (g, fx) -> stack flow [ (push f for f in reverse fx)..., pop g, last ]

use = curry (client, data) ->
  if client.run? then client.run {data} else {client, data}

url = curry rtee (value, context) -> context.url = new URL

base = curry rtee (value, context) -> context.base = value

path = curry rtee (value, context) ->
  context.path = value
  context.url = new URL value, context.base

query = curry rtee (object, context) ->
  for key, value of object
    context.url.searchParams.append key, value

template = curry rtee (value, context) ->
  context.template = URLTemplate.parse value

parameters = transform rtee (object, context) ->
  context.url = context.template.expand object

content = curry rtee (value, context) -> context.body = value

headers = curry rtee (object, context) -> context.headers = object

accept = curry rtee (value, context) ->
  (context.headers ?= {}).accept = value

method = curry rtee (value, context) -> context.method = value

authorize = curry rtee (value, context) ->
  (context.headers ?= {}).authorize = value

cache = do (cache = {}, {method, url, cached} = {}) ->
  curry (requestor, context) ->
    {url, method} = context
    if (cached = cache[url]?[method])?
      await cached
    else
      (cache[url] ?= {})[method] = requestor context

request = tee (context) -> context.response = await context.client context

expect = curry rtee (codes, context) ->
  if ! context.response.status in codes
    throw failure "unexpected status", context

ok = (context) ->
  if !context.response.ok
    throw failure "not ok", context

text = tee (context) -> context.text = await context.response.text()

json = tee (context) -> context.json = await context.response.json()

blob = tee (context) -> context.blob = await context.response.blob()

data = curry (builder, context) -> await builder context.data

Fetch =

  client: do ({type, credentials} = {}) ->
    curry ({fetch, mode}, {url, method, headers, body}) ->
      fetch url, {method, headers, body,  mode}

Zinc =

  grants: do ({profile, key} = {}) ->
    curry rtee (builder, context) ->
      profile = await Profile.current
      throw failure "no current profile" if !profile?
      key = await builder context
      profile.receive key, context.json.directory

  claim: do ({profile, path, claim} = {}) ->
    ({url, parameters, method}) ->
      profile = await Profile.current
      throw failure "no current profile" if !profile?
      # TODO consider another term for path
      path = url.pathname + url.search
      if (claim = profile.exercise {path, parameters, method})?
        capability: claim
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
            path: url.pathname
            date: new Date().toISOString()
            hash: (hash Message.from "utf8", JSON.stringify body).to "base64"
      sigil: declaration.to "base64"

export {cast, use, events, resource, url, base, path,
  query, template, parameters, content, headers,
  accept, method, authorize, cache, request, expect, ok,
  text, json, blob,
  data, Fetch, Zinc}
