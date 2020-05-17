import {curry} from "panda-garden"

property = curry (name, value) -> value[name]

export default property
