async = require 'async'
request = require 'request'
_ = require 'lodash'

{Emission, County} = require '../data'

Emission.find({}).exec (err, emissions) ->
  console.log(err) if err
  console.log("no emissions") unless emissions.length > 0

  counties = {}
  async.eachLimit emissions, 5, (emission, eCb) ->
    longitude = emission.Longitude
    latitude = emission.Latitude
    request("http://data.fcc.gov/api/block/find?format=json&latitude=#{latitude}&longitude=#{longitude}&showall=true", (err, _res, body) ->
      return eCb(err) if err
      return eCb(body) unless _res.statusCode == 200
      body = JSON.parse(body)
      name = body["County"]["name"]
      fips = body["County"]["FIPS"]
      state = body["State"]["name"]
      counties[name] ||= {
        name: name
        fips: fips
        state: state
        sulfur: 0,
        voc: 0,
        nox: 0
      }
      if (emission["Pollutant"] == "Sulfur Dioxide")
        counties[name]["sulfur"] += emission["Emissions in Tons"]
      else if (emission["Pollutant"] == "Nitrogen Oxides")
        counties[name]["nox"] += emission["Emissions in Tons"]
      else if (emission["Pollutant"] == "Volatile Organic Compounds")
        counties[name]["voc"] += emission["Emissions in Tons"]
      console.log name
      eCb(null)
    )
  , (err) ->
    console.log 'error' if err
    console.log err if err

    counties = _.values(counties)
    async.eachLimit counties, 5, (county, eCb) ->
      county = new County
        name: county.name
        state: county.state
        fips: county.fips
        sulfur: county.sulfur
        nox: county.nox
        voc: county.voc
      county.save eCb
    , (err) ->
      console.log 'saving error' if err
      console.log err if err
      console.log 'finished' unless err
      process.exit()
