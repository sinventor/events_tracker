window.EventTrackerApp = {}

window.EventTrackerApp.ajaxRequests =
  save: (url, resource_fields, params) ->
    url = url
    url += '?' + $.param(params) if params
    $.ajax
      url: url
      data: resource_fields
      dataType: 'json'
      type: 'POST'
  del: (url, resource_id, params) ->
    url = url + "/#{resource_id}"
    url += '?' + $.param(params) if params
    $.ajax
      url: url
      dataType: 'json'
      type: 'DELETE'
  update: (url, resource_id, resource_fields, params) ->
    url = url + "/#{resource_id}"
    url += '?' + $.param(params) if params
    $.ajax
      url: url
      data: resource_fields
      dataType: 'json'
      type: 'PUT'
  extract: (url, params) ->
    url += '?' + $.param(params) if params
    $.ajax
      url: url
      dataType: 'json'

