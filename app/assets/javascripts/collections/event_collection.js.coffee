EventsTracker.Collections.Event = Backbone.Collection.extend
  model: EventsTracker.Models.Event
  
  url: ->
    '/events'