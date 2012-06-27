support = require 'lib/support'
# Utilities
# ---------
module.exports = utils =

  # Object Helpers
  # --------------

  # Prototypal delegation. Create an object which delegates
  # to another object.
  beget: do ->
    if typeof Object.create is 'function'
      Object.create
    else
      ctor = ->
      (obj) ->
        ctor:: = obj
        new ctor

# Make properties readonly and not configurable
  # using ECMAScript 5 property descriptors
  readonly: do ->
    if support.propertyDescriptors
      readonlyDescriptor =
        writable: false
        enumerable: true
        configurable: false
      (obj, properties...) ->
        for prop in properties
          Object.defineProperty obj, prop, readonlyDescriptor
        true
    else
      ->
        false
# Finish
# ------

# Seal the utils object
Object.seal? utils
