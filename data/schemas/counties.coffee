mongoose = require 'mongoose'
Schema = mongoose.Schema

CountySchema = new Schema(
  name: String,
  sulfur: Number,
  voc: Number,
  nox: Number
)

module.exports = CountySchema