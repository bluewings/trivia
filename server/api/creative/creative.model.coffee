'use strict'

mongoose = require('mongoose')

Schema = mongoose.Schema

CreativeSchema = new Schema(
  nccCreativeId: String
  nccGroupId: String
  customerId: Number
  inspectStatus:
    type: Number
    default: 10
  creativeTp: Number
  creative: String
  isMainCreative:
    type: Number
    default: 0
  preNccCreativeId: String
  nccBusinessId: String
  delFlag: 
    type: Number
    default: 0
  delTm: Date
  regTm:
    type: Date
    default: Date.now
  editTm: Date
  inspectedTm: Date
  inspectRequestTm: Date
)

module.exports = mongoose.model('Creative', CreativeSchema)
