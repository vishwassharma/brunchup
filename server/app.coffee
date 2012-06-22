express = require 'express'
gzippo = require 'gzippo'


exports.startServer = (port, path, callback = (->)) ->
  # Starting the server here
  server = express.createServer()

  # declare middle ware here
  server.use express.bodyParser()
  server.use express.methodOverride()
  server.use express.cookieParser()
  server.use express.session secret : 'adofi02394lk324j2lkjlsdfjlsdj09329jklsdajlfd'
  
  server.use (request, response, next) ->
    response.header 'Cache-Control', 'no-cache'
    next()

  server.use express.static path

  server.all "/*", (request, response) ->
    response.sendfile sysPath.join path, 'index.html'

  server.listen parseInt port, 10
  server.on 'listening', callback
  server

