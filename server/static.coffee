module.exports = (app) ->
  path = require 'path'
  cors = require 'cors'
  express = require 'express'
  oneDay = 1000 * 60 * 60 * 24
  app.use '/dist', [cors(), express.static path.join(__dirname, '../', 'dist'), maxAge: oneDay]