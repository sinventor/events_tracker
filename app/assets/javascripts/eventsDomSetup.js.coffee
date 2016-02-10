$ ->
  $startDate = $('#startDate')
  $startTime = $('#startTime')
  $endDate = $('#endDate')
  $endTime = $('#endTime')

  $('#startDate').datepicker(
    dateFormat: 'yy-mm-dd'
    onSelect: (dateText) ->
      $('#endDate').datepicker('option', 'minDate', $(@).datepicker('getDate'))
      $('#endDateOfSeries').datepicker('option', 'minDate', $(@).datepicker('getDate'))
  )

  $('#endDate').datepicker(
    dateFormat: 'yy-mm-dd'
    onSelect: (dateText) ->
      $('#startDate').datepicker('option', 'maxDate', $(@).datepicker('getDate'))
      $('#endDateOfSeries').datepicker('option', 'minDate', $(@).datepicker('getDate'))
  )

  $('#endDateOfSeries').datepicker(
    dateFormat: 'yy-mm-dd'
    onSelect: (dateText) ->
      $('#startDate').datepicker('option', 'maxDate', $(@).datepicker('getDate'))
      $('#endDate').datepicker('option', 'maxDate', $(@).datepicker('getDate'))
  )
  $('#startTime').val('15:00')
  $('#endTime').val('15:20')

  _.each ['startTime', 'endTime'], (timeId) ->
    $('#' + timeId).on 'focusout', (e) ->
      comp = moment($('#startDate').val() + ' ' + $('#startTime').val())
      comp2 = moment($('#endDate').val() + ' ' + $('#endTime').val())
      $time = $('#' + timeId)
      $time.val('10:00') unless utils.checkTimeCorrectness($time.val())

  _.each [$startDate, $startTime, $endDate, $endTime], (stamp) ->
    stamp.on 'focusout', (e) ->
      ensureDateTimePeriodIsValid()

  ensureDateTimePeriodIsValid = () ->
    startDate = $startDate.val()
    startTime = $startTime.val()
    endDate = $endDate.val()
    endTime = $endTime.val()
    start = startDate + (if startTime? then ' ' + startTime else '')
    end = endDate + (if endTime? then ' ' + endTime else '')

    if moment(end).isBefore(moment(start))
      if moment(startDate).isAfter(endDate)
        endDate = startDate
        end = endDate + (if endTime? then ' ' + endTime else '')
        console.log $endDate.val(startDate)
      if moment(start).isAfter(end)
        $endTime.val($startTime.val())

  $('#popupEvent').on 'hidden.bs.modal', () ->
    flushEventFields()

  $('#markedAsPeriodic').bind('change', (e) ->
    $('.end-series-date-area').toggleClass('hide')
  )

  flushEventFields = () ->
    $('#title').val('')
    $('#startDate').val('')
    $('#startTime').val('14:00')
    $('#endTime').val('14:20')
    $('#endDateOfSeries').val('')
    $('#repeatInterval option[value=""]').prop('selected', 'selected')
    $('.end-series-date-area').addClass('hide')
    $('.bulk-update-area').addClass('hide')
