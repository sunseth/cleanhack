{Emission, County} = require '../data'

module.exports = (app) ->

  app.get '/', (req, res, next) ->
    res.render 'index'

  app.get '/counties', (req, res, next) ->
    County.find({}).exec (err, counties) ->
      console.log err if err
      console.log 'no counties' unless counties.length > 0
      res.send {counties: counties}