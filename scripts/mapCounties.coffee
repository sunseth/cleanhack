async = require 'async'
request = require 'request'

{Emission} = require '../data'

Emission.find({}).exec (err, emissions) ->
  console.log(err) if err
  console.log("no emissions") unless emissions.length > 0

  async.eachLimit emissions, 5, (emission, eCb) ->
    longitude = emission.Longitude
    latitude = emission.Latitude
    request("http://data.fcc.gov/api/block/find?format=json&latitude=#{latitude}&longitude=#{longitude}&showall=true", (err, _res, body) ->
      return eCb(err) if err
      return eCb(body) unless _res.statusCode == 200
      body = JSON.parse(body)
      name = body["County"]["name"]
      console.log name
      emission.County = name
      emission.save eCb
    )
  , (err) ->
    console.log 'error' if err
    console.log err if err
    console.log 'finished'
    process.exit()