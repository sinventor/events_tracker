window.ETRUtils or= {}
ETRUtils.sessionHelpers =
  isUserSignedIn: () ->
    perhapsCookieValue = ETRUtils.cookieHelpers.getCookieByName('signed_in')
    perhapsCookieValue && perhapsCookieValue == "1"