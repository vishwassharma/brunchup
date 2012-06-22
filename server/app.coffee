express = require 'express'
gzippo = require 'gzippo'
sysPath = require 'path'

# get the global variables here
router = require './router'

MemStore = express.session.MemoryStore


exports.startServer = (port, path, callback = (->)) ->
  # Starting the server here
  server = express.createServer()

  # declare middle ware here
  server.configure ->
    server.use express.bodyParser()
    server.use express.methodOverride()
    server.use express.cookieParser()
    server.use express.session
      secret : 'adofi02394lk324j2lkjlsdfjlsdj09329jklsdajlfd'
      store : new MemStore
        reapInterval : 50000 * 10
    server.use express.csrf()
    server.use router
    server.use express.static path
    server.use (req, response, next) ->
      response.header 'Cache-Control', 'no-cache'
      next()
    
  server.get '/', router.index
  server.get '/login', router.login

  server.all "/*", (request, response) ->
    response.sendfile sysPath.join path, '404.html'

  server.listen parseInt port, 10
  server.on 'listening', callback
  server
