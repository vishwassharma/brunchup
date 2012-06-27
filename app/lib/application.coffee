mediator = require 'lib/mediator'
Layout = require 'lib/views/layout'
Router = require 'lib/router'
# The application bootstrapper.

class Application

  title : ''

  # define karo internal variables jo ki aage aane waale hai 
  layout : null
  router : null

  constructor : ->
    @initialize arguments...

  initialize: ->

  initializeMediator : ->
    # initialize any global objects .. 
    # iske baad moka nahi milega
    mediator.seal()

  initializeRouter : ->
    @router = new Router

  initializeLayout : (options = {}) ->
    options.title ?= @title
    @layout = new Layout options
    # add a view which will more or less look like the resumes


  # Disposal
  # --------

  disposed: false

  dispose: ->
    return if @disposed

    properties = ['dispatcher', 'layout', 'router']
    for prop in properties
      this[prop].dispose()
      delete this[prop]

    @disposed = true

    # Your're frozen when your heart’s not open
    Object.freeze? this


module.exports = Application
