EventsTracker.Models.Event = Backbone.Model.extend
  urlRoot: ->
    '/events'

  initialize: ->
    @now = new Date()

  defaults:
    title: ''
    startDate: moment(@now).format('YYYY-MM-DD')
    startTime: moment(@now).format('HH:mm')
    endDate: moment(@now).format('YYYY-MM-DD')
    endTime: moment(@now).add(25, 'minutes').format('HH:mm')
    repeat_interval: null

  composeDateTime: (date, time) ->
    result = date
    result += ' ' + time
    result

  toJSON: ->
    title: @get('title')
    start: @composeDateTime(@get('startDate'), @get('startTime'))
    end: @composeDateTime(@get('endDate'), @get('endTime'))
    repeat_interval: @get('repeat_interval')