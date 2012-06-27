# Base class for all models.
utils = require "lib/utils"
Subscriber = require 'lib/subscriber'

class Model extends Backbone.Model
  # Mixin for mediator
  _.extend @::, Subscriber

  # This method is used to get the attributes for the view template
  # and might be overwritten by decorators which cannot create a
  # proper `attributes` getter due to ECMAScript 3 limits.
  getAttributes: ->
    @attributes

  # Private helper function for serializing attributes recursively,
  # creating objects which delegate to the original attributes
  # when a property needs to be overwritten.
  serializeAttributes = (model, attributes, modelStack) ->
    # Create a delegator on initial call
    #console.log model, attributes, modelStack
    unless modelStack
      delegator = utils.beget attributes
      modelStack = [model]
    else
      # Add model to stack
      modelStack.push model
    # Map model/collection to their attributes
    for key, value of attributes
      if value instanceof Model
        # Don’t change the original attribute, create a property
        # on the delegator which shadows the original attribute
        delegator ?= utils.beget attributes
        delegator[key] = if value is model or value in modelStack
          # Nullify circular references
          null
        else
          # Serialize recursively
          serializeAttributes(
            value, value.getAttributes(), modelStack
          )
      else if value instanceof Backbone.Collection
        delegator ?= utils.beget attributes
        delegator[key] = for item in value.models
          serializeAttributes(
            item, item.getAttributes(), modelStack
          )

    # Remove model from stack
    modelStack.pop()
    # Return the delegator if it was created, otherwise the plain attributes
    delegator or attributes
  
  # Return an object which delegates to the attributes
  # (i.e. an object which has the attributes as prototype)
  # so primitive values might be added and altered safely.
  # Map models to their attributes, recursively.
  serialize: (model) ->
    serializeAttributes this, @getAttributes()

module.exports = Model
