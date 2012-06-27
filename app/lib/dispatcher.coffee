Subscriber = require 'lib/subscriber'

class Dispatcher

  _.extend @::, Subscriber

  constructor : ->
    @initialize arguments...

  initialize : (options) ->
    @subscriberEvent 'matchRoute', @matchRoute

  matchRoute : (options) ->
    console.log options

modular.exports = Dispatcher
