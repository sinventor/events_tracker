$ ->
  $calendar = $('#userCalendar')
  deletedEventId = null
  editedEventId = null
  calLoading = true
  hasSameBaseItems = false
  mode = 'create'
  update_same = null
  editedEvent = null
  $title = $('#title')
  $startDate = $('#startDate')
  $startTime = $('#startTime')

  fetchSame = (event_id) ->
    EventTrackerApp.ajaxRequests.extract('/events/get_same', id: event_id)

  prepareEventFields = (calEvent) ->
    $title.val(calEvent.title)
    $startDate.val(utils.formatBaseDate(calEvent.start))
    $startTime.val(utils.formatBaseTime(calEvent.start))
    $('#endDate').val(utils.formatBaseDate(calEvent.end)) if calEvent.end
    $('#endTime').val(utils.formatBaseTime(calEvent.end)) if calEvent.end
    $('.end-series-date-area').fadeOut()
    $('.bulk-update-area').removeClass('hide') if hasSameBaseItems

    if calEvent.repeat_interval
      $('#markedAsPeriodic').prop('checked', true)
      $('.end-series-date-area').removeClass('hide')
    else
      $('#markedAsPeriodic').prop('checked', false)
      $('.end-series-date-area').addClass('hide')
    $('#popupEventHeader').text('Редактирование события')
    $('#deleteEventBtn').removeClass('hide')

  nullifyIntermediateFields = ->
    hasSameBaseItems = null
    editedEvent = null
    editedEventId = null

  resetEventFields = ->
    $title.val('')
    $startTime.val('15:00')

  getEditedEventFields = () ->
    res = {}
    res.title = $('#title').val() if $('#title').val() != editedEvent.title
    res.start = composeStartDate()
    res.end_date = composeEndDate()
    event: res

  externalEventDropped = (date, allDay, externalEvent) ->
    console.log(date)
    newData = {}
    newData.event = {}
    newData.event.start = moment.utc(date.start._d).format('YYYY-MM-DD HH:mm:ss')
    newData.event.end = moment.utc(date.end._d).format('YYYY-MM-DD HH:mm:ss') if date.end

    EventTrackerApp.ajaxRequests.update('/events', date.id, newData, update_same: true, recompute: true)
          .then (data) ->
            $calendar.fullCalendar('refetchEvents')

  setupNewEventFields = (date) ->
    utils.emptyFields('.field_error')
    $('#markedAsPeriodic').prop('checked', false)
    $('#startDate').val(moment(date).format('YYYY-MM-DD'))
    $('#endDate').datepicker('option', 'minDate', $('#startDate').val())
    $('#endDate').val(moment(date).format('YYYY-MM-DD'))
    $('#startDate').datepicker('option', 'maxDate', $('#endDate').val())
    $('#popupEventHeader').text('Новое событие')
    $('#deleteEventBtn').addClass('hide')

  setupEditEventFields = (calEvent) ->
    $('.field_error').empty()
    $('#editedTitle').val(calEvent.title)
    $('#editedStart').val(calEvent.start)
    deletedEventId = calEvent.id

  getEventFields = () ->
    start = 
    end_date = composeEndDate()
    event = {}
    event.title = $('#title').val()
    event.start = composeStartDate()
    event.end_date = end_date
    event.repeat_interval = $('#repeatInterval').val() if $('#markedAsPeriodic').prop('checked') && repeat_interval: $('#repeatInterval').val()
    event: event
      
      
  getAdditionalFields = () ->
    if $('#markedAsPeriodic').prop('checked')
      return {
        series_end: $('#endDateOfSeries').val()
      }

  getAdditionalUpdateParams = () ->
    if editedEvent.repeat_interval
      update_same: $('input[name=updateOptions]:checked').val() == 'all'

  getAdditionalDeleteParams = ->
    if hasSameBaseItems
      delete_same: true if $('input[name=deleteOptions]:checked').val() == 'all'

  composeStartDate = ->
    result = $('#startDate').val()
    result += ' ' + $('#startTime').val() if $('#startTime').val()
    result

  composeEndDate = ->
    result = $('#endDate').val()
    result += ' ' + $('#endTime').val() if $('#endTime').val()
    result

  trySave = (event) ->
    EventTrackerApp.ajaxRequests.save('/events', event, getAdditionalFields())
        .then (data) ->
          $('#popupEvent').modal('hide')
          $calendar.fullCalendar('refetchEvents')
          resetEventFields()
        ,
        (data) ->
          _.each data.responseJSON, (v, k) ->
            console.log('ke', k)
            console.log('va', v)
            $(".#{k}_errors").append($('span')).text(v.join(', '))

  tryUpdate = (event) ->
    EventTrackerApp.ajaxRequests.update('/events', editedEvent.id, event, getAdditionalUpdateParams())
            .then (d) ->
              $('#popupEvent').modal('hide')
              $calendar.fullCalendar('refetchEvents')
              update_same = null
              resetEventFields()
              nullifyIntermediateFields()
            ,
            (d) ->
              _.each(d.responseJSON, (v, k) ->
                console.log("#{k} -- #{v}")
                $(".#{k}_errors").append($('p')).text(v.join(', '))
              )   


  tryDelete = (event_id) ->
    EventTrackerApp.ajaxRequests.del('/events', event_id, getAdditionalDeleteParams()).then (d) ->
      console.log('dele', d)
      $calendar.fullCalendar('refetchEvents')
    ,
    (d) ->
      console.log('failed', d)
    nullifyIntermediateFields()

  initializeCalendar = () ->   
    $('#userCalendar').fullCalendar
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source'
      header:
        left: 'today, prev,next',
        center: 'title',
        right: 'month,agendaWeek'
      defaultView: 'month'
      editable: true
      selectable: true
      allDaySlot: true
      eventLimit: 3
      events: '/events'
      eventColor: '#9aa9cb'
      
      eventClick: (calEvent, jsEvent, view) ->
        mode = 'update'
        editedEvent = calEvent
               
        editedEventId = calEvent.id
        fetchSame(calEvent.id).then (data) ->
          hasSameBaseItems = _.any(data)
          prepareEventFields(calEvent)
          $('#popupEvent').modal('show')
        
      eventDrop: (date, allDay, md, ald, revf) ->
        externalEventDropped(date, allDay, @)
      eventResize: (event, dayDelta) ->
        console.log(dayDelta)
      dayClick: (date, jsEvent, view) ->
        mode = 'create'
        setupNewEventFields(date)
        $('#popupEvent').modal('show')

  $('#eventForm').submit (e) ->
    e.preventDefault()
    if mode == 'create' 
      trySave(getEventFields())
    else
      tryUpdate(getEditedEventFields())

  initializeCalendar() if ETRUtils.sessionHelpers.isUserSignedIn()
  
  $('#deleteEventBtn').on 'click', (e) ->
    e.preventDefault()
    $('#popupEvent').modal('hide')
    if hasSameBaseItems
      $('#popupDeleteOneBasedModal').modal('show')
    else
      tryDelete(editedEvent.id)
    return

  $('#deleteApplyBtn').on 'click', (e) ->
    e.preventDefault()
    $('#popupDeleteOneBasedModal').modal('hide')
    tryDelete(editedEvent.id)

  return