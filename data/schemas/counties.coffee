mongoose = require 'mongoose'
Schema = mongoose.Schema

CountySchema = new Schema(
  name: String,
  state: String,
  fips: Number,
  sulfur: Number,
  voc: Number,
  nox: Number
)

module.exports = CountySchema