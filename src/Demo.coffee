require('./globals')
Psha = require 'psha'
clc  = require 'cli-color'

colors =
  has      : clc.green
  missing  : clc.red

module.exports =
  class Demo
    constructor: (opts) ->
      opts ?= {}

      config =
        ttl: 5*1000
        update: (keys, cb) =>
          @requested = keys
          @show()
          @requested = []
          @update(keys, (err, pairs) ->
            cb(err, pairs))

        clear: (key, value, ts) =>
          @cleared = [key]
          @show()
          @cleared = []

      @requested = []
      @cleared = []
      @domain = opts.domaim or [1..15]
      @cache = new Psha(config)

    update: (keys, cb) ->
      setTimeout(->
        rs = {}
        for k in keys
          rs[k] = { id: k }
        cb(null, rs)

      , _.random(1000, 2000))

    start: ->
      setInterval(=>
        keys = _.sample(@domain, 4)
        @cache.get(keys, (err, res) => @show(res))
        @show()
      , 1000)

    show: ->
      pending = @cache.getPendingKeys()

      s = []

      s.push('Requesting:'); @addArray(s, @requested)
      s.push(', Pending:');    @addArray(s, pending)
      s.push(', Cached:');      @addArray(s, _.keys(@cache._cache))
      s.push(', Cleared:');     @addArray(s, @cleared)

      console.log(s.join(""))

    addArray: (buf, ar, contains) ->
      ar = _.map(ar, (r) -> Number(r))
      buf.push('[')

      ar ?= []
      for k in @domain
        color = if k in ar then colors.has else colors.missing

        v = color(' ' + k)

        buf.push(v)

      buf.push(' ]')
