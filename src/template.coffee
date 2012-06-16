module.exports = ->
  html ->
    head -> 
      title 'Cloudq Status'
      link rel: 'stylesheet', href: '/css/bootstrap.min.css'
      link rel: 'stylesheet', href: '/css/bootstrap-responsive.min.css'
    body ->
      div '.container', ->
        h1 style: 'margin-top:50px;margin-bottom:40px;', 'Cloudq Status'
        table '.table', ->
          tr ->
            th 'Name'
            th style: 'color: red', 'Queued'
            th style: 'color: orange', 'Reserved'
            th style: 'color: green', 'Completed'
          for k, v of @qResults
            tr ->
              td k
              td style: 'color: read', (v.queued or '0')
              td style: 'color: orange', (v.reserved or '0')
              td style: 'color: green', (v.completed or '0')
      script src: 'http://cdnjs.cloudflare.com/ajax/libs/jquery/1.7.2/jquery.min.js'
      script src: '/js/bootstrap.min.js'
