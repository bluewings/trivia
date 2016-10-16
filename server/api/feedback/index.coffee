'use strict'

express = require('express')
http = require('http')
querystring = require('querystring')
router = express.Router()

COOKIE = 'PLAY_SESSION="2c40d18033be5d348b0f760627a131aa9bcac8d5-loginId=skywalker&userId=8023&userName=%EC%B0%A8%EC%84%B1%EC%9B%90"; neoidTempSessionKey=n0StaszLO5KWFEM1; wcs_bt=a77c2f282d91e8:1442549007' 

# sampleImg = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABpklEQVR4Xu2bQU4CMRSG/265gmJYkxBxxRVY6lHmBOIJ5ii65AiyEkPCViJ6BbaYJpCQ0aGv0yby+v7ZkbyUvm/6vZdOWgcA/QXusUcNYOB/G3g2cKi2E7y4Q/LPBpL+naLDg+u/4sPQm29C2HgAe5Nv/5A0AXAFUAHWABZBdgHDBNgG2QbZBtkG2Qa7NoHPSRy76WqM9e49+Hex494sXHDMtoCkLhA70fVuienqLjjZ2HHVAPCZ198z1F9PZyEUDcBnHlKheAAhFYoHEFLBBIBzKpgB0KaCGQBtKpgC8JcK5gA0VTAHoKmCSQCnKpgFcFTBLICjCtXVLLhhOg1QtRmKykwYTABavgf4rXDs8pYsAjUrwE90PnrDsDeW5CWOUQVg2LvFfLQUJycJVAXAJ1RdP2ZVQR0ADyGnCioB5FRBJYCcKqgFkEsF1QByqKAaQA4V1ANIVaEIACkqFAEgRYViAHRVoSgAXVT4NwCSjcqlxySdD7j05CTzIwAek+MxOR6TizvqJaksimJYBFkEWQRZBFkEFRXt7FPl1Vnzl6f9mrJ8ff4H6zVp7GFz6zQAAAAASUVORK5CYII='

yobiBoardPath = 'skywalker/meanwhile-crawler'

uploadImage = (dataURL, callback = ->) ->

  matches = dataURL.match(/^data:image\/([a-z]+);base64,(.*)$/)
  if matches and matches.length is 3
    imageFormat = matches[1]
    base64str = matches[2]
    boundaryKey = '----WebKitFormBoundary' + Math.random().toString(36).replace(/^.*\./, '')

    req = http.request 
      host: 'yobi.navercorp.com'
      path: '/files'
      port: '80'
      method: 'POST'
      headers:
        Accept: '*/*'
        Cookie: COOKIE
        'Content-Type': 'multipart/form-data; boundary="' + boundaryKey + '"'
    , (response) ->
      if response.statusCode isnt 200
        callback new Error('upload failed. ' + response.statusCode)

      else
        result = ''
        response.on 'data', (chunk) ->
          result += chunk
          return

        response.on 'end', ->
          try
            result = JSON.parse result

          if result and typeof result is 'object'
            callback null, result
          else
            callback new Error('upload failed.')
          return

      return
     
    req.write "--#{boundaryKey}\r\n"
    req.write 'Content-Disposition: form-data; name="filePath"; filename="screenshot-feedback.' + imageFormat + '"\r\n' + 'Content-Type: image/' + imageFormat + '\r\n\r\n' 
    req.write new Buffer(base64str, 'base64')
    req.end "\r\n--#{boundaryKey}--"

  else
    callback new Error('invalid dataURL.')

  return

postIssue = (title = '', body = '', uploaded, callback = ->) ->

  if uploaded and uploaded.id
    body = "![#{uploaded.name}](#{uploaded.url})\r\n\r\n" + body
    temporaryUploadFiles = uploaded.id
  else
    temporaryUploadFiles = ''

  req = http.request 
    host: 'yobi.navercorp.com'
    path: '/' + yobiBoardPath + '/issues/latest'
    port: '80'
    method: 'POST'
    headers:
      Accept: '*/*'
      Cookie: COOKIE
      'Content-Type': 'application/x-www-form-urlencoded'
  , (response) ->
    if response.statusCode >= 400 
      callback new Error('post issue failed. ' + response.statusCode)
    else
      callback null, 'success'

    return

  req.write querystring.stringify
    title: title
    body: body
    temporaryUploadFiles: temporaryUploadFiles
    'assignee.user.id': -1

  req.end()

router.post '/', (req, res) ->

  # console.log req.body

  if req.body and req.body.title and req.body.body and req.body.dataURL
    uploadImage req.body.dataURL, (err, data) ->
      if err
        res.send 500, err
      else
        postIssue req.body.title, req.body.body, data, (err, data) ->
          if err
            res.send 500, err
          else
            res.json 200, data

  else
    res.send 400

  return

module.exports = router