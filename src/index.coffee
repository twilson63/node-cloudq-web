path = require 'path'
[ http, request, zeke, url, filed, template] = [
  require 'http'
  require 'request'
  require 'zeke'
  require 'url'
  require 'filed'
  require path.join(__dirname, 'template')
  ]

cloudq = process.env.VIEW_URL or 'http://localhost:3000/api'
view = cloudq + '/queues?group=true'

module.exports = ->
  server = http.createServer (req, res) ->
    pathname = url.parse(req.url).pathname
    if req.url == '/' and req.method is 'GET'
      # get queues summary
      request uri: view, json: true, (e, r, b) -> 
          return res.end 'DB Not Found.' if e?
          render b, (err, html) -> res.end html
    else
      filed(__dirname + "/public#{pathname}").pipe(res)
  server.listen process.env.PORT or 4000

# generate coffeecup template
render = (body, cb) ->
  cb null, zeke.render(template, qResults: transform(body.rows))

# convert rows into queue stats object
transform = (rows) ->
  results = {}
  for item in rows
    [queue, state] = item.key.split('-')
    results[queue] ?= {}
    results[queue][state] = item.value
  return results
