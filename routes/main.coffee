_ = require 'lodash'
{Emission, County} = require '../data'

module.exports = (app) ->

  app.get '/', (req, res, next) ->
    res.render 'index'

  app.get '/counties', (req, res, next) ->
    County.find({}).exec (err, counties) ->
      console.log err if err
      console.log 'no counties' unless counties.length > 0
      res.send {counties: counties}

  app.post '/offender', (req, res, next) ->
    body = JSON.parse(_.keys(req.body)[0])
    {county} = body
    {type} = body
    console.log county, type, body


    Emission.find({County: county, Pollutant: type}).sort({ "Emissions in Tons": -1 }).exec (err, emissions) ->
      console.log err if err
      console.log 'no emissions' unless emissions.length > 0

      res.send emissions?[0]