mediator = require 'lib/mediator'
Subscriber = require 'lib/subscriber'

class Layout # This class does not extend View

  # Mixin a Subscriber
  _.extend @::, Subscriber

  # The site title used in the document title
  # This should be set in your app-specific Application class
  # and passed as an option
  title: ''

  # An hash to register events, like in Backbone.View
  # It is only meant for events that are app-wide
  # independent from any view  events: {}

  # Register @el, @$el and @cid for delegating events
  el: document
  $el: $(document)

  constructor: ->
    @initialize arguments...

  initialize: (options) ->
    @title = options.title

  # Disposal
  # --------

  disposed: false

  dispose: ->
    return if @disposed

    @unsubscribeAllEvents()

    delete @title

    @disposed = true

    # Your're frozen when your heart’s not open
    Object.freeze? this

module.exports = Layout
