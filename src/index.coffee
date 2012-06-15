http = require 'http'
request = require 'request'
zeke = require 'zeke'
url = require 'url'
filed = require 'filed'

#db = process.env.DB_URL or 'http://localhost:5984/cloudq'
#db = 'https://jackhq:jackdog63@gmms.iriscouch.com/cloudq'
db = 'http://localhost:5984/cloudq'

queueTemplate = ->
  html ->
    head -> 
      title 'Cloud Queue Status'
      link rel: 'stylesheet', href: '/css/bootstrap.min.css'
      link rel: 'stylesheet', href: '/css/bootstrap-responsive.min.css'
    body ->
      div '.container', ->
        h1 'GMMS Queue Status'
        table '.table', ->
          tr ->
            th 'Name'
            th 'Queued'
            th 'Reserved'
            th 'Completed'
          for k, v of @qResults
            tr ->
              td k
              td v.queued or '0'
              td v.reserved or '0'
              td v.completed or '0'
      script src: 'http://cdnjs.cloudflare.com/ajax/libs/jquery/1.7.2/jquery.min.js'
      script src: '/js/bootstrap.min.js'

module.exports = ->
  server = http.createServer (req, res) ->
    pathname = url.parse(req.url).pathname
    if pathname.match /^\/(css|img|js)/
     filed("./public#{pathname}").pipe(res)
    else if req.method is 'GET'
      # Cool beans
      request db + '/_design/queues/_view/all?group=true', json: true, (e, r, b) ->
        res.writeHead 404, 'content-type': 'text/html'
        results = {}
        for item in b.rows
          [queue, state] = item.key.split('-')
          results[queue] ?= {}
          results[queue][state] = item.value
        res.end zeke.render(queueTemplate, qResults: results)
    else
      # no food for you
      res.writeHead 404, 'content-type': 'text/plain'
      res.end 'Request Not Found'

  server.listen process.env.PORT or 3000