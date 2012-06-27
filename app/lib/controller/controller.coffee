mediator = require 'lib/mediator'
Subscriber = require 'lib/subscriber'

class Controller

  _.extend @::, Subscriber

  currentId : null

  constructor : ->
    @initialize arguments...

  # initialize the function
  initialize : (options) ->


  # Disposal
  # --------

  disposed: false

  dispose: ->
    return if @disposed

    # Dispose and delete all members which are disposable
    for own prop of this
      obj = this[prop]
      if obj and typeof obj.dispose is 'function'
        obj.dispose()
        delete this[prop]

    # Unbind handlers of global events
    @unsubscribeAllEvents()

    # Remove properties
    properties = ['currentId']
    delete this[prop] for prop in properties

    # Finished
    @disposed = true

    # You're frozen when your heart’s not open
    Object.freeze? this


module.exports = Controller
