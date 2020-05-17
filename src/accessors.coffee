import property from "./property"

resources = ({api, resource}) -> property "resources", api

resource = (context) -> property context.resource, resources context

template = (context) -> property "template", resource context

methods = (context) -> property "methods", resource context

method = (context) -> property context.method, methods context

signatures = (context) -> property "signatures", method context

request = (context) -> property "request", signatures context

response = (context) -> property "response", signatures context

accept = (context) ->
  "application/json" if (property "schema", response context)?

media = (context) ->
  "application/json" if (property "schema", request context)?

expect =

  media: (context) ->
    "application/json" if (property "schema", response context)?

  status: (context) -> property "status", response context

accessors = {resources, resource, template, methods, method,
  signatures, request, response, accept, media, expect}

export default accessors
