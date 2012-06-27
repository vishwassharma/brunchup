application = require 'application'
mediator = require 'lib/mediator'
ProviderHomeController = require 'controller/provider_home'
ResumeController = require 'controller/resume'
JobsController = require 'controller/jobs'
HomePageController = require 'controller/home'
SeekerController = require 'controller/seeker'

module.exports = class Router extends Backbone.Router

  routes:
    '' : 'home'
    'seeker/:id' : 'seeker_home'
    'provider/:id' : 'provider_home'
    'jobs/:id' : 'jobs'
    'resume/:id' : 'resume'
    'callback' : 'callback'


  callback : ->
    mediator.publish 'login', @
    mediator.publish 'loginSuccess', @
    console.log window.opener.application
    #window.close()

  home : ->
    controller = new HomePageController
    controller.render()

  provider_home: (id) ->
    controller = new ProviderHomeController
    controller.render()

  resume : (id) ->
    resumePage = new ResumeController
    resumePage.home id
    #$('#magic').html application.resumeView.render().el

  jobs: (id) ->
    console.log "here"
    jobPage = new JobsController
    jobPage.home id
    # view = application.jobsView
    #$('#magic').html application.jobsView.render().el
    #$('#container').html application.jobsView.render().el

  seeker : (id) ->
    console.log "[Router] Seeker #{id}"
    seekerPage = new SeekerController
    seekerPage.home id
