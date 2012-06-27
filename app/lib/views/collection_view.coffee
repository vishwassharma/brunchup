View = require './view'

# Base class for all views.
module.exports = class CollectionView extends View

  # Hash which saves all item views by model CID
  viewsByCid: null
  # Track a list of the visible views
  visibleItems: null

  # A collection view may have a template and use one of its child elements
  # as the container of the item views. If you specify `listSelector`, the
  # item views will be appended to this element. If empty, $el is used.
  listSelector: null

  # The actual element which is fetched using `listSelector`
  $list: null
  

  initialize : (options={}) ->
    super

    # Default options
    # These are stored as normal properties, not in Backbone’s options hash
    # so derived classes may override them when calling super.
    _(options).defaults
      render: true      # Render the view immediately per default
      renderItems: true # Render all items immediately per default
      filterer: null    # No filter function

    @itemView = options.itemView if options.itemView?
    # Initialize lists for views and visible items
    @viewsByCid = {}
    @visibleItems = []

    # Debugging
    # @bind 'visibilityChange', (visibleItems) ->
    #   console.debug 'visibilityChange', visibleItems.length
    # @modelBind 'syncStateChange', (collection, syncState) ->
    #   console.debug 'syncStateChange', syncState

    # Start observing the collection
    @addCollectionListeners()

    # Render template once
    @render() if options.render

    # Render all items initially
    @renderAllItems() if options.renderItems

  # Returns an instance of the view class
  # This is not simply a property with a constructor so that
  # several item view constructors are possible depending
  # on the item model type.
  getView: (model) ->
    if @itemView?
      new @itemView({model})
    else
      throw new Error 'The CollectionView#itemView property must be
defined (or the getView() must be overridden)'

  addCollectionListeners : ->
    @modelBind 'add',    @itemAdded
    @modelBind 'remove', @itemRemoved
    @modelBind 'reset',  @itemsResetted


  # Main render method (should be called only once)
  render: ->
    super
    # Set the $list property
    @$list = if @listSelector then @$(@listSelector) else @$el

    #@initFallback()
    #@initLoadingIndicator()


  itemAdded : (item,  options = {}) =>
    console.log item
    console.log "item added"
    @renderAndInsertItem item, options.index

  itemRemoved: (item) =>
    console.log "Remove item"
    #@removeViewForItem item

  itemsResetted: =>
    console.log "Render all items #{@constructor.name}"
    @renderAllItems()

  # Item view rendering
  # -------------------
  # Render and insert all items
  renderAllItems: =>
    items = @collection.models

    # Reset visible items
    @visibleItems = []

    # Collect remaining views
    remainingViewsByCid = {}
    for item in items
      view = @viewsByCid[item.cid]
      if view
        # View remains
        remainingViewsByCid[item.cid] = view

    # Remove old views of items not longer in the list
    for own cid, view of @viewsByCid
      # Check if the view remains
      unless cid of remainingViewsByCid
        # Remove the view
        @removeView cid, view

    # Re-insert remaining items; render and insert new items
    for item, index in items
      # Check if view was already created
      view = @viewsByCid[item.cid]
      if view
        # Re-insert the view
        @insertView item, view, index, 0
      else
        # Create a new view, render and insert it
        @renderAndInsertItem item, index

    # If no view was created, trigger `visibilityChange` event manually
    unless items.length
      @trigger 'visibilityChange', @visibleItems

  # Render the view for an item
  renderAndInsertItem: (item, index) ->
    view = @renderItem item
    @insertView item, view, index

  # Instantiate and render an item using the viewsByCid hash as a cache
  renderItem: (item) ->
    # Get the existing view
    view = @viewsByCid[item.cid]

    # Instantiate a new view by calling getView if necessary
    unless view
      view = @getView(item)
      # Save the view in the viewsByCid hash
      @viewsByCid[item.cid] = view

    # Render in any case
    view.render()

    view

  # Inserts a view into the list at the proper position
  insertView: (item, view, index = null, animationDuration = @animationDuration) ->
    # Get the insertion offset
    position = if typeof index is 'number'
      index
    else
      @collection.indexOf item


    # Get the view’s top element
    viewEl = view.el
    $viewEl = view.$el

    # Insert the view into the list
    $list = @$list

    # Get the children which originate from item views
    children = $list.children (@itemSelector or undefined)
    length = children.length

    if length is 0 or position is length
      # Insert at the end
      $list.append viewEl
    else
      # Insert at the right position
      if position is 0
        $next = children.eq position
        $next.before viewEl
      else
        $previous = children.eq position - 1
        $previous.after viewEl


    # Tell the view that it was added to the DOM
    view.trigger 'addedToDOM'


  # Remove the view for an item
  #removeViewForItem: (item) ->
    ##Remove item from visibleItems list, trigger a `visibilityChange` event
    #@updateVisibleItems item, false

    ## Get the view
    #view = @viewsByCid[item.cid]

    #@removeView item.cid, view

    ## Remove a view
  removeView: (cid, view) ->
    # Dispose the view
    view.dispose()

    # Remove the view from the hash
    delete @viewsByCid[cid]

  # List of visible items
  # ---------------------

  # Update visibleItems list and trigger a `visibilityChanged` event
  # if an item changed its visibility
  #updateVisibleItems: (item, includedInFilter, triggerEvent = true) ->
    #visibilityChanged = false

    #visibleItemsIndex = _(@visibleItems).indexOf item
    #includedInVisibleItems = visibleItemsIndex > -1

    #if includedInFilter and not includedInVisibleItems
      ##Add item to the visible items list
      #@visibleItems.push item
      #visibilityChanged = true

    #else if not includedInFilter and includedInVisibleItems
      ##Remove item from the visible items list
      #@visibleItems.splice visibleItemsIndex, 1
      #visibilityChanged = true

    ##Trigger a `visibilityChange` event if the visible items changed
    #if visibilityChanged and triggerEvent
      #@trigger 'visibilityChange', @visibleItems

    #visibilityChanged

  # Disposal
  # --------

  dispose: ->
    return if @disposed

    # Dispose all item views
    view.dispose() for own cid, view of @viewsByCid

    # Remove jQuery objects, item view cache and visible items list
    properties = [
      '$list', '$fallback', '$loading',
      'viewsByCid', 'visibleItems'
    ]
    delete this[prop] for prop in properties

    # Self-disposal
    super
