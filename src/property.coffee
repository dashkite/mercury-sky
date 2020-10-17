import {curry} from "@pandastrike/garden"

property = curry (name, value) -> value[name]

export default property
