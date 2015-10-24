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
    {county} = req?.body
    {type} = req?.body
    console.log county, type, req.body

    Emission.find({County: county, Pollutant: type}).sort({ "Emissions in Tons": -1 }).exec (err, emissions) ->
      console.log err if err
      console.log 'no emissions' unless emissions.length > 0
      console.log emissions

      res.send emissions?[0]