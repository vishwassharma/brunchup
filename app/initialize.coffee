Application = require 'application'

$ ->
  # Fill this with your database information.
  # `ddocName` is the name of your couchapp project.
  #Backbone.couch_connector.config.base_url = "http://localhost:5984/"
  # If set to true, the connector will listen to the changes feed
  # and will provide your models with real time remote updates.
  console.log "[Initialize.coffee] Application Initialization"
  window.application = new Application

  #application.initialize()
  Backbone.history.start()

  $("a[rel=popover]")
      .popover()
      .click (e)->
        e.preventDefault()
  
  $("a[rel=tooltip]")
      .tooltip()
      .click (e)->
        e.preventDefault()
