path = require 'path'
[ http, request, zeke, url, filed, template] = [
  require 'http'
  require 'request'
  require 'zeke'
  require 'url'
  require 'filed'
  require path.join(__dirname, 'template')
  ]

db = process.env.DB_URL or 'http://localhost:5984/cloudq'
view = db + '/_design/queues/_view/all'
module.exports = ->
  server = http.createServer (req, res) ->
    pathname = url.parse(req.url).pathname
    if req.url == '/' and req.method is 'GET'
      # get queues summary
      request view + '?group=true'
        json: true 
        (e, r, b) -> render b, (err, html) -> res.end html
    else
      filed("./public#{pathname}").pipe(res)
  server.listen process.env.PORT or 3000

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

# need to create views if they don't exist
# createView if not_found
request view, json: true, (e, r, b) ->
  if b.error is "not_found"
    console.log 'create view'
    request.put db + '/_design/queues', 
      json: 
        language: 'javascript'
        views: 
          all:
            map: "function (doc) { emit(doc.queue + '-' + doc.queue_state, 1); }"
            reduce: "function (keys, values) { return sum(values); }"
      (e, r, b) -> console.log b


  