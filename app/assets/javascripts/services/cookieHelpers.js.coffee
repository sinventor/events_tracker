window.ETRUtils or= {}
ETRUtils.cookieHelpers =
  getCookieByName: (name) ->
    value = '; ' + document.cookie
    parts = value.split('; ' + name + '=')
    if parts.length == 2
      return parts.pop().split(';').shift()
    else
      return null