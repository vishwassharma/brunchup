require 'lib/view_helper'
Subscriber = require 'lib/subscriber'

# Base class for all views.
module.exports = class View extends Backbone.View
  # Mixin a Subscriber
  _(@prototype).extend Subscriber

  # trigger the render function if true
  autoRender : false

  # check if there are any subviews
  hasSubView : false

  # a list of subviews and a dictionary containing all the subview
  subViews : null
  subViewsByName : null
  filter : false

  # Automatic inserting into DOM
  # ----------------------------
  # View container element
  # Set this property in a derived class to specify the container element.
  # Normally this is a selector string but it might also be an element or
  # jQuery object.
  # The view is automatically inserted into the container when it’s rendered.
  # As an alternative you might pass a `container` option to the constructor.
  container: null

  # What should be the way by which we should add the element
  # This can me modified to either of 
  # `html` == this will change the content of html inside the tag
  # `append` == 
  # Like jQuery’s `html`, `prepend`, `append`, `after`, `before` etc.
  containerMethod : 'html'

  initialize : (options= {})->

    _.extend @, options

    # check if it has sub view
    if @hasSubView
      @subViews = []
      @subViewsByName = {}

    # if autoRender then fire render
    if @autoRender
      @render()

  addSubView : (name, view, where, attr=null) =>
    options =
      el: where

    if attr
      options = _.extend {}, options, attr

    # initialize the view
    v = new view options
    v.parent = @

    # add ]ub view for other reference
    @subViews.push v
    @subViewsByName[name] = v
    v
    
  
  template: ->
    return

  # Rendering
  # ---------

  # Get the model/collection data for the templating function
  getTemplateData: ->
    if @model
      # Serialize the model
      templateData = @model.serialize()
    else if @collection
      # Collection: Serialize all models
      items = []
      for model in @collection.models
        items.push model.serialize()
      templateData = {items}
    else
      # Empty object
      templateData = {}


    # some more data will be available on chaplin
    templateData

  getRenderData: ->
    return

  render: (attr=null) =>
    @beforeRender()
    console.debug "Rendering #{@constructor.name}"
    data = @getTemplateData()
    # Add additional data to template
    if attr
      data = _.extend {}, data, attr

    # check if filter exist
    # if yes then filter the data
    if @filter
      data = @filter(data)
    #@$el[@containerMethod] @template @getRenderData()
    html = @template data
    #@$el.empty().append html
    @$el.html html
    @afterRender()
    this

  beforeRender : ->
    #console.log "Before Render"
    return

  afterRender: ->
    if @container
      $(@container)[@containerMethod] @el
      @trigger 'addedToDom'
    @


  # User input event handling
  # -------------------------

  # Event handling using event delegation
  # Register a handler for a specific event type
  # For the whole view:
  #   delegate(eventType, handler)
  #   e.g.
  #   @delegate('click', @clicked)
  # For an element in the passing a selector:
  #   delegate(eventType, selector, handler)
  #   e.g.
  #   @delegate('click', 'button.confirm', @confirm)
  delegate: (eventType, second, third) ->
    if typeof eventType isnt 'string'
      throw new TypeError 'View#delegate: first argument must be a string'

    if arguments.length is 2
      handler = second
    else if arguments.length is 3
      selector = second
      if typeof selector isnt 'string'
        throw new TypeError 'View#delegate: ' +
          'second argument must be a string'
      handler = third
    else
      throw new TypeError 'View#delegate: ' +
        'only two or three arguments are allowed'

    if typeof handler isnt 'function'
      throw new TypeError 'View#delegate: ' +
        'handler argument must be function'

    # Add an event namespace
    eventType += ".delegate#{@cid}"

    # Bind the handler to the view
    handler = _(handler).bind(this)

    if selector
      # Register handler
      @$el.on eventType, selector, handler
    else
      # Register handler
      @$el.on eventType, handler

    # Return the bound handler
    handler

  # Remove all handlers registered with @delegate

  undelegate: ->
    @$el.unbind ".delegate#{@cid}"

  # Model binding
  # The following implementation resembles subscriber.coffee
  # --------------------------------------------------------
  # Model binding
  # The following implementation resembles subscriber.coffee
  # --------------------------------------------------------
  # Bind to a model event
  modelBind: (type, handler) ->
    if typeof type isnt 'string'
      throw new TypeError 'View#modelBind: ' +
        'type must be a string'
    if typeof handler isnt 'function'
      throw new TypeError 'View#modelBind: ' +
        'handler argument must be function'

    # Get model/collection reference
    modelOrCollection = @model or @collection
    unless modelOrCollection
      throw new TypeError 'View#modelBind: no model or collection set'

    # Ensure that a handler isn’t registered twice
    modelOrCollection.off type, handler, this

    # Register model handler, force context to the view
    modelOrCollection.on type, handler, this

  # Unbind from a model event
  modelUnbind: (type, handler) ->
    if typeof type isnt 'string'
      throw new TypeError 'View#modelUnbind: ' +
        'type argument must be a string'
    if typeof handler isnt 'function'
      throw new TypeError 'View#modelUnbind: ' +
        'handler argument must be a function'

    # Get model/collection reference
    modelOrCollection = @model or @collection
    return unless modelOrCollection

    # Remove model handler
    modelOrCollection.off type, handler

  # Unbind all recorded model event handlers
  modelUnbindAll: () ->
    # Get model/collection reference
    modelOrCollection = @model or @collection
    return unless modelOrCollection

    # Remove all handlers with a context of this view
    modelOrCollection.off null, null, this

  # Disposal
  # --------

  disposed: false

  dispose: ->
    return if @disposed

    # Dispose subviews
    #subview.dispose() for subview in @subviews

    # Unbind handlers of global events
    @unsubscribeAllEvents()

    # Unbind all model handlers
    @modelUnbindAll()

    # Remove all event handlers on this module
    @off()

    # Remove the topmost element from DOM. This also removes all event
    # handlers from the element and all its children.
    @$el.remove()

    # Remove element references, options,
    # model/collection references and subview lists
    properties = [
      'el', '$el',
      'options', 'model', 'collection',
      'subviews', 'subviewsByName',
      '_callbacks'
    ]
    delete this[prop] for prop in properties

    # Finished
    @disposed = true

    # You’re frozen when your heart’s not open
    Object.freeze? this
