global._ = require('lodash')

console.json = (args...) ->
  console.log.apply(console, _.map(args, (a) -> JSON.stringify(a, null, '  ')))
