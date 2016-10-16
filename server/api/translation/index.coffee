'use strict'

express = require('express')
glob = require('glob')
fs = require('fs')
async = require('async')

router = express.Router()

# 전체 번역본을 모두 찾는다
getTranslations = (convert, callback = ->) ->

  glob "#{__dirname}/../../../public/assets/i18n/*.json", (err, files) ->
    return callback(err) if err
    
    reads = []
    for file in files
      do (file) ->
        reads.push (eachCallback) -> 
          fs.readFile file, 'utf8', (err, data) ->
            return eachCallback(err) if err
            try
              data = JSON.parse data
            catch
              data = {}
            eachCallback(null, {
              lang: file.replace(/^.*\-([a-z]+\-[a-z]+)\.json$/i, '$1')
              data: data
            })
          return

    async.parallel reads, (err, data) ->
      return callback(err) if err
      if convert
        result = {}
        for each in data
          result[each.lang] = each.data
        callback null, result
      else
        callback null, data
    return
  return

pathValue = (object, fullpath, value) ->
  paths = fullpath.split('.')
  current = object
  unless value
    # get path value
    for path in paths
      current = current[path]
      unless current
        return ''
    return current

  # set path value
  for path, i in paths
    unless current
      return
    if i < paths.length - 1
      current = current[path]
    else
      current[path] = value
  return

# 특정노드의 언어별 번역을 찾는다.
getTranslation = (translationId, callback = ->) ->
  getTranslations true, (err, data) ->
    return callback(err) if err
    result = {}
    for langKey, value of data
      if data.hasOwnProperty langKey
        result[langKey] = pathValue(value, translationId)
    callback null, result
    return

  return

# 특정노드의 언어별 번역을 찾는다.
setTranslation = (translationId, transition, callback = ->) ->
  getTranslations false, (err, data) ->
    return callback(err) if err
    writes = []
    for each in data
      if transition[each.lang]
        file = "#{__dirname}/../../../public/assets/i18n/locale-#{each.lang}.json"
        pathValue(each.data, translationId, transition[each.lang])
        jsonData = each.data
        do (file, jsonData) ->
          writes.push (eachCallback) -> 
            fs.writeFile file, JSON.stringify(jsonData, null, 2), 'utf8', (err, data) ->
              return eachCallback(err) if err
              eachCallback(null, {})
            return

    async.parallel writes, (err, data) ->
      return callback(err) if err
      callback null, true
    return

  return

# 번역 내용 조회
router.get '/:id', (req, res) ->
  getTranslation req.params.id, (err, data) ->
    return res.send(500, err) if err
    res.json data
  return

# 번역 내용 갱신
router.put '/:id', (req, res) ->
  body = ''

  req.on 'data', (chunk) ->
    body += chunk
    return

  req.on 'end', ->
    try
      body = JSON.parse body
    catch
      body

    setTranslation req.params.id, body, (err, data) ->
      return res.send(500, err) if err
      res.json data

  return

module.exports = router
