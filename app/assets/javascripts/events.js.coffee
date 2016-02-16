currentEvent = null

initializeCalendar = ->
  $('#userCalendar').fullCalendar
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
    header:
      left: 'today,prev,next'
      center: 'title'
      right: 'month,agendaWeek'
    defaultView: 'month'
    editable: true
    selectable: true
    eventLimit: 3
    events: '/events'

    dayClick: (date, jsEvent, view) ->
      currentEvent = new EventsTracker.Models.Event
        startDate: moment(date).format('YYYY-MM-DD')
        endDate: moment(date).format('YYYY-MM-DD')
      $('#popupEvent').modal('show')

    eventClick: (calEvent, jsEvent, view) ->
      currentEvent = new EventsTracker.Models.Event
        id: calEvent.id
        title: calEvent.title
        repeat_interval: calEvent.repeat_interval
        startDate: moment(calEvent.start).format('YYYY-MM-DD')
        startTime: moment(calEvent.start).format('HH:mm')
        endDate: moment(calEvent.end).format('YYYY-MM-DD')
        endTime: moment(calEvent.end).format('HH:mm')

      $('#deleteEventBtn').removeClass('hide')
      $('#popupEventHeader').text("Event's editing")

      $.getJSON '/events/get_same.json?id=' + currentEvent.get('id'), (data) ->
        currentEvent.set('has_same', true) if _.any(data)
        $('#popupEvent').modal('show')

    eventDrop: (data, allDay) ->
      externalEventDropped(data, allDay, @)

fillEventModalFields = ->
  if currentEvent
    $('#title').val(currentEvent.get('title'))
    $('#startDate').val(currentEvent.get('startDate'))
    $('#startTime').val(currentEvent.get('startTime'))
    $('#endDate').val(currentEvent.get('endDate'))
    $('#endTime').val(currentEvent.get('endTime'))
    if currentEvent.get('repeat_interval')
      $('#markedAsPeriodic').prop('checked', true)
      $('.end-series-date-area').removeClass('hide')
    if currentEvent.get('has_same') && currentEvent.get('has_same') == true
      $('.bulk-update-area').removeClass('hide')

flushEventModalFields = ->
  $('#title').val('')
  $('#startDate').val('')
  $('#startTime').val('')
  $('#endDate').val('')
  $('#endTime').val('')
  $('#markedAsPeriodic').prop('checked', false)
  $('#endDateOfSeries').val('')
  $('#repeatInterval option[value=""]').prop('selected', 'selected')
  $('.end-series-date-area').addClass('hide')
  $('.bulk-update-area').addClass('hide')

refetchEvents = ->
  $('#userCalendar').fullCalendar('refetchEvents')

externalEventDropped = (data, allDay, externalEvent) ->
  $.ajax
    url: "/events/#{data.id}?recompute=t&update_same=t"
    dataType: 'json'
    type: 'PUT'
    data: 
      event:
        start: moment.utc(data.start._d).format('YYYY-MM-DD HH:mm')
    success: (d) ->
      refetchEvents()

$ ->
  initializeCalendar() if EventsTracker.Services.isUserSignIn()
  $('#popupEvent').on 'show.bs.modal', (e) ->
    fillEventModalFields()

  $('#popupEvent').on 'hidden.bs.modal', (e) ->
    flushEventModalFields()

  $('#markedAsPeriodic').bind 'change', (e) ->
    $('.end-series-date-area').toggleClass('hide')
  $('#startDate').datepicker
    dateFormat: 'yy-mm-dd'
    onSelect: (dateText) ->
      $('#endDate').datepicker('option', 'minDate', $(@).datepicker('getDate'))

  $('#endDate').datepicker
    dateFormat: 'yy-mm-dd'
    onSelect: (dateText) ->
      $('#startDate').datepicker('option', 'maxDate', $(@).datepicker('getDate'))
      $('#endDateOfSeries').datepicker('option', 'minDate', $(@).datepicker('getDate'))

  $('#endDateOfSeries').datepicker
    dateFormat: 'yy-mm-dd'

  $('#eventForm').on 'submit', (e) ->
    e.preventDefault()
    currentEvent.set('title', $('#title').val())
    currentEvent.set('startDate', $('#startDate').val())
    currentEvent.set('startTime', $('#startTime').val())
    currentEvent.set('endDate', $('#endDate').val())
    currentEvent.set('endTime', $('#endTime').val())
    if $('#markedAsPeriodic').prop('checked')
      currentEvent.set('series_end', $('#endDateOfSeries').val())
      currentEvent.set('repeat_interval', $('#repeatInterval').val())
    newUrl = currentEvent.url()

    if currentEvent.isNew()
      seriesEnd = currentEvent.get('series_end')      
      newUrl += "?series_end=#{seriesEnd}" if seriesEnd   
    else
      newUrl += "?update_same=true" if currentEvent.get('has_same') && $('input[name=updateOptions]:checked').val() == 'all'

    currentEvent.save(null,
      url: newUrl
    ).then (d) ->
        currentEvent = null 
        refetchEvents()
        $('#popupEvent').modal('hide')
    , (d) ->
        _.each d.responseJSON.errors, (fieldErrors, fieldName) ->
          $(".#{fieldName}_errors").append($('span')).text(fieldErrors.join(', '))
    
  $('#deleteEventBtn').on 'click', (e) ->
    e.preventDefault()
    if currentEvent.get('has_same') && $('input[name=updateOptions]:checked').val() == 'all'
      currentEvent.destroy(data: {delete_same: true}, processData: true)
    else
      currentEvent.destroy()
    refetchEvents()
    $('#popupEvent').modal('hide')

    