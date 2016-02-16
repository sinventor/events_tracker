EventsTracker.Services.isUserSignIn = ->
  getCookieByName = (name) ->
    value = '; ' + document.cookie
    parts = value.split('; ' + name + '=')
    parts.pop().split(';').shift() if parts.length == 2
    
  perhapsCookie = getCookieByName('signed_in')
  perhapsCookie && perhapsCookie == '1'