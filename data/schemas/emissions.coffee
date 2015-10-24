mongoose = require 'mongoose'
Schema = mongoose.Schema

EmissionSchema = new Schema(
  "Facility Name": String,
  "Facility Address": String,
  "Latitude": Number,
  "Longitude": Number,
  "NAICS Code": Number,
  "Pollutant": String,
  "Source Type": String,
  "Emissions in Tons": Number,
  "Year": Number
  "County": String
)

module.exports = EmissionSchema