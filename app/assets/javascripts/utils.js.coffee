window.utils =
  emptyFields: ($fields...)->
    $.each $fields, (i, field) ->
      $(field).empty()
      return
    return
  checkHoursCorrectness: (hours) ->
    parsedHours = parseInt(hours)
    /\d{2}/.test(hours) && parsedHours >= 0 && parsedHours < 24
  checkMinutesCorrectness: (minutes) ->
    parsedMinutes = parseInt(minutes)
    /\d{2}/.test(minutes) && parsedMinutes >= 0 && parsedMinutes < 60
  checkTimeCorrectness: (time) ->
    hoursAndMinutes = time.split(':')
    return false if hoursAndMinutes.length != 2
    @checkHoursCorrectness(hoursAndMinutes[0]) && @checkMinutesCorrectness(hoursAndMinutes[1])
  formatBaseDate: (date) ->
    moment(date).format('YYYY-MM-DD')
  formatBaseTime: (date) ->
    moment(date).format('HH:mm')
