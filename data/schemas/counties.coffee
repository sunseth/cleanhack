mongoose = require 'mongoose'
Schema = mongoose.Schema

CountySchema = new Schema(
  name: String,
  state: String,
  fips: String,
  sulfur: Number,
  voc: Number,
  nox: Number
)

module.exports = CountySchema