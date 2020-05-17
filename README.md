# Mercury-Sky

Mercury (HTTP) combinators for use with Sky APIs.

```coffeescript
import {property} from "panda-garden"
import {cast} from "@dashkite/katana"
import {use, content, authorize, json} from "@dashkite/mercury"
import Sky from "@dashkite/mercury-sky"

{discover, resource, method, request} = Sky

getPerson = flow [
  use Fetch.client mode: "cors"
  discover "https://api.acme.org"
  resource "people"
  cast query, [ property "data" ]
  method "get"
  request
  json
  property "json"
]

do ->
  alice = await getPerson name: "Alice"
```

This augments the base [Mercury](https://github.com/dashkite/mercury) combinators with Panda Sky aware combinators.

## Install

```
npm i @dashkite/mercury
npm i @dashkite/mercury-sky
```

## API

#### discover url

Make a discovery request against the given URL for the Sky API description. The result is placed into the request context using the `api` property and cached in memory to avoid redundant requests.

#### resource name

Sets the URL template based on the Sky API description.

#### method name

Replaces the Mercury `method` combinator. Checks that the method is supported for the given resource and sets the method and headers, if applicable, based on the given resource and method.

#### request

Replaces the Mercury `request` combinator. Performs the request but validates that the response matches the expected response for the given resource and method.