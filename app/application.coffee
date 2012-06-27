mediator = require 'lib/mediator'
Layout = require 'lib/views/layout'
Router = require 'lib/router'
App = require 'lib/application'
# The application bootstrapper.
NavigationController = require 'controller/navigation'
BreadCrumController = require 'controller/breadcrum'

class Application extends App

  title : 'HireVoice'

  initialize: (options) ->
    console.log "[Application.coffee] Initialization function"
    super
    # Ideally, initialized classes should be kept in controllers & mediator.
    # If you're making big webapp, here's more sophisticated skeleton
    # https://github.com/paulmillr/brunch-with-chaplin
    @initializeMediator()
    @initializeRouter()
    @initializeLayout()
    @initializeController()

    # instantiate the router
    # Freeze the object
    #Object.freeze? this
    # Freeze the application instance to prevent further changes
    Object.freeze? this
  
  initializeController : ->
    console.log "[Application.coffee] Initialization Controller"
    new NavigationController()
    new BreadCrumController()

  initializeMediator : ->
    console.log "[Application.coffee] Initialization Mediator"
    # initialize any global objects .. 
    # iske baad moka nahi milega
    #mediator.user = null
    mediator.seal()

  initializeRouter : ->
    console.log "[Application.coffee] Initialization Router"
    @router = new Router

  initializeLayout : ->
    console.log "[Application.coffee] Initialization Layout"
    layout = new Layout {@title}

module.exports = Application
