'use strict'

_ = require('lodash')
Creative = require('./creative.model')

###*
# Using Rails-like standard naming convention for endpoints.
# GET     /creatives              ->  index
# POST    /creatives              ->  create
# GET     /creatives/:id          ->  show
# PUT     /creatives/:id          ->  update
# DELETE  /creatives/:id          ->  destroy
###

# http://docs.mongodb.org/manual/reference/operator/query/
getQuery = (filtering) ->
  query = {}
  try
    filtering = JSON.parse(filtering)
  if !Array.isArray(filtering) and typeof filtering is object
    filtering = [filtering]
  if Array.isArray(filtering)  
    for filter in filtering
      if filter.field and filter.operator and typeof filter.value isnt 'undefined'
        unless query[filter.field]
          query[filter.field] = {}
        operator = filter.operator.toLowerCase()
        if ['eq', 'gt', 'gte', 'lt', 'lte', 'ne'].indexOf(operator) isnt -1 and !Array.isArray(filter.value)
          query[filter.field]["$#{operator}"] = filter.value
        if ['in', 'nin'].indexOf(operator) isnt -1
          if !Array.isArray(filter.value)
            filter.value = [ filter.value ]
          query[filter.field]["$#{operator}"] = filter.value
  query

handleError = (res, err) ->
  res.send 500, err

# Get list of creatives
exports.index = (req, res) ->
  Creative.find (err, creatives) ->
    if err
      return handleError(res, err)
    res.json 200, creatives
  return

# Get a single creative
exports.show = (req, res) ->
  Creative.findById req.params.id, (err, creative) ->
    if err
      return handleError(res, err)
    if !creative
      return res.send(404)
    res.json creative
  return

# Creates a new creative in the DB.
exports.create = (req, res) ->
  Creative.create req.body, (err, creative) ->
    if err
      return handleError(res, err)
    res.json 201, creative
  return

# Updates an existing creative in the DB.
exports.update = (req, res) ->
  if req.body._id
    delete req.body._id
  Creative.findById req.params.id, (err, creative) ->
    if err
      return handleError(res, err)
    if !creative
      return res.send(404)
    updated = _.merge(creative, req.body)
    updated.save (err) ->
      if err
        return handleError(res, err)
      res.json 200, creative
    return
  return

# Deletes a creative from the DB.
exports.destroy = (req, res) ->
  Creative.findById req.params.id, (err, creative) ->
    if err
      return handleError(res, err)
    if !creative
      return res.send(404)
    creative.remove (err) ->
      if err
        return handleError(res, err)
      res.send 204
    return
  return