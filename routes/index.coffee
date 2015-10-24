express = require 'express'
engine = require 'ejs-locals'

config = require '../config'

module.exports = (app) ->
  app.engine 'ejs', engine
  app.set 'views', "#{__dirname}/../views"
  app.set 'view engine', 'ejs'

  app.use '/', express.static("#{__dirname}/../public")
  app.express = express

  require('./main')(app)