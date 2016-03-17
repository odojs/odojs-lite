whakaruru = require 'whakaruru'
whakaruru ->
  express = require 'express'
  app = express()

  require('./server/static') app
  require('./server/root') app

  mutunga = require 'http-mutunga'
  pjson = require './package.json'
  port = 8080
  server = mutunga(app).listen port, ->
    host = server.address().address
    boundport = server.address().port
    shutdown = ->
      console.log "#{pjson.name}@#{pjson.version} ōhākī waiting for requests to finish"
      server.close ->
        console.log "#{pjson.name}@#{pjson.version} e noho rā!"
        process.exit 0
    console.log "#{pjson.name}@#{pjson.version} has started listening on #{host}:#{boundport}"
    process.on 'SIGTERM', shutdown
    process.on 'SIGINT', shutdown
