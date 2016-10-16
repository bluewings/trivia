'use strict'

fs = require('fs')
path = require('path')
async = require('async')
rmdir = require('rimraf')
spawn = require('child_process').spawn
slideRoot = path.join(__dirname, '..', '..', '..', 'public', 'slides')
importTmp = path.join(__dirname, '..', '..', '..', '_import')

uid = ->
  parseInt(Math.random() * 900000000 + 100000000, 10).toString(36).substr 0, 6

getDirs = (srcpath, cb) ->
  fs.readdir srcpath, (err, files) ->
    if err
      console.error err
      return cb([])

    iterator = (file, cb) ->
      fs.stat path.join(srcpath, file), (err, stats) ->
        if err
          console.error err
          return cb(false)
        cb stats.isDirectory()
        return
      return

    async.filter files, iterator, cb
    return
  return

getSlide = (slideId, callback) ->
  slidePath = path.join(slideRoot, slideId)
  fs.exists slidePath, (exists) ->
    if !exists
      callback 'slide not found.'
      return
    fs.readFile path.join(slidePath, 'index.json'), 'utf8', (err, data) ->
      if err
        callback 'cannot read slide.'
        return
      try
        data = JSON.parse(data)
      catch err
        callback err
        return
      callback null, data
      return
    return
  return  

prepare = ->
  fs.exists slideRoot, (exists) ->
    if !exists
      fs.mkdir slideRoot, (err) ->
        if err and err and err.code != 'EEXIST'
          throw err
        return
    return

  fs.exists importTmp, (exists) ->
    if !exists
      fs.mkdir importTmp, (err) ->
        if err and err and err.code != 'EEXIST'
          throw err
        return
    return
  return

prepare()

exports.index = (req, res) ->
  fs.readdir slideRoot, (err, files) ->
    if err
      res.json 500, err
      return
    parallels = []
    files.forEach (file) ->
      parallels.push (callback) ->
        fs.readFile path.join(slideRoot, file, 'index.json'), 'utf8', (err, data) ->
          if !err
            try
              data = JSON.parse(data)
          callback null, data
          return
        return
      return
    async.parallel parallels, (err, results) ->
      if err
        res.send 500, err
        return
      slides = []
      for each in results
        if each and each.id
          slides.push each
      res.json 200, slides
      return
    return
  return

checkPath = (path, callback) ->
  fs.exists path, (exists) ->
    if exists
      callback null, path
    else
      fs.mkdir path, (err) ->
        if !err or err and err.code == 'EEXIST'
          callback null, path
        else
          callback err
        return
    return
  return

exports.create = (req, res, next) ->
  if !req.user
    res.json 401, 'Unauthorized for this job.'
    return
  if !req
    req = body: title: 'test'
  if !req.body.title
    res.json 400, 'title is required.'
    return
  req.body.id = req.body.title.replace(/[^a-zA-Z0-9ㄱ-ㅎ가-힣 ]/g, '').trim().replace(/\s+/g, '-').toLowerCase()
  checkPath slideRoot, (err, callback) ->
    if err
      res.json 500, err
      return
    slidePath = path.join(slideRoot, req.body.id)
    fs.exists slidePath, (exists) ->
      if exists
        random = uid()
        slidePath += "-#{random}"
        req.body.id += "-#{random}"
      checkPath slidePath, (err, callback) ->
        req.body.author =
          _id: req.user._id
          name: req.user.name
          email: req.user.email
          provider: req.user.provider
        fs.writeFile path.join(slidePath, 'index.json'), JSON.stringify(req.body, null, 2), (err) ->
          if err
            res.json 500, err
            return
          fs.writeFile path.join(slidePath, 'slide.md'), req.body.markdown, (err) ->
            if err
              res.json 500, err
              return
            res.json req.body
            return
          return
        return
    return
  return

exports.show = (req, res, next) ->
  slidePath = path.join(slideRoot, req.params.id)
  fs.exists slidePath, (exists) ->
    if !exists
      res.send 401
      return
    fs.readFile path.join(slidePath, 'index.json'), 'utf8', (err, data) ->
      if err
        res.send 500, err
        return
      try
        data = JSON.parse(data)
      catch err
        res.send 500, err
        return
      res.json 200, data
      return
    return
  return

exports.update = (req, res, next) ->
  slidePath = path.join(slideRoot, req.params.id)
  fs.exists slidePath, (exists) ->
    if !exists
      res.send 401
      return
    fs.writeFile path.join(slidePath, 'index.json'), JSON.stringify(req.body, null, 2), (err) ->
      if err
        res.json 500, err
        return
      fs.writeFile path.join(slidePath, 'slide.md'), req.body.markdown, (err) ->
        if err
          res.json 500, err
          return
        res.json req.body
        return
    return
  return

exports.destroy = (req, res) ->
  slidePath = path.join(slideRoot, req.params.id)
  console.log slidePath
  rmdir slidePath, (err) ->
    if err
      res.send 500, err
      return
    res.send 204
    return
  return

exports.export = (req, res, next) ->
  fs.exists path.join(slideRoot, req.params.id), (exists) ->
    if !exists
      res.statusCode = 404
      res.write 'package not found'
      res.end()
      return
    tar = spawn('tar', ['-C', slideRoot, '-cvf', '-', req.params.id])
    res.contentType 'tar'
    tar.stdout.on 'data', (data) ->
      res.write data
      return
    tar.stderr.on 'data', (data) ->
    tar.on 'exit', (code) ->
      if code != 0
        res.statusCode = 500
        console.log 'zip process exited with code ' + code
        res.end()
      else
        res.end()
      return
    return
  return

exports.import = (req, res, next) ->


  unless req

    req = 
      params:
        id: 'test'

      files:
        file: null

  unless res
    res = 
      json: ->
      send: ->


  if !req.files or !req.files.file
    res.send 500, 'Upload file not found.'
    return
  else
    if Array.isArray req.files.file
      file = req.files.file[0]
    else
      file = req.files.file


  unless file
    file =
      path: path.join(slideRoot, '..', '..', 'down.tar')


  getSlide req.params.id, (err, data) ->

    if err
      res.json 500, err
      return    

    importPath = path.join(importTmp, uid())

    cleanPath = ->
      console.log importPath
      rmdir importPath, ->
        console.log 'do nothing'

    slidePath = path.join(slideRoot, req.params.id)

    fs.mkdir importPath, (err) ->
      if err and err and err.code != 'EEXIST'
        throw err

      tar = spawn('tar', ['-C', importPath, '-xvf', file.path]);
      # results = []
      # tar.stdout.on 'data', (data) ->
      #   results.push data.toString()
      # tar.stderr.on 'data', (data) ->
      #   results.push data.toString()
      
      tar.on 'exit', (code) ->
        if code > 0
          # fail
          console.log 'fail'
          # console.log results.join('')
        else
          # success
          # console.log 'success'


          getDirs importPath, (dirs) ->
            if dirs and dirs.length is 1

              targetPath = path.join(importPath, dirs[0])

              fs.readFile path.join(targetPath, 'index.json'), 'utf8', (err, newData) ->

                try
                  newData = JSON.parse(newData)
                catch

                  # error
                  return
                  
                

                # newData = JSON.parse(newData)

                # console.log data

                # console.log newData

                # console.log newData.author
                # console.log data.author
                # author 정보를 덮어쓴다
                oldSlideId = newData.id
                newData.id = req.params.id
                newData.author = data.author
                newData.access = req.params.access

                writeData = ->



                  fs.writeFile path.join(slidePath, 'index.json'), JSON.stringify(newData, null, 2), (err) ->


                    if err
                      res.json 500, err
                      return
                    fs.writeFile path.join(slidePath, 'slide.md'), newData.markdown, (err) ->
                      if err
                        res.json 500, err
                        return
                      res.json 200, newData
                      cleanPath()

                fs.exists path.join(targetPath, 'img'), (exists) ->

                  if exists

                    rmdir path.join(slidePath, 'img'), ->

                      fs.rename path.join(targetPath, 'img'), path.join(slidePath, 'img'), (err) ->
                        # console.log err

                        fs.readdir path.join(slidePath, 'img'), (err, files) ->
                          
                          for file in files
                            # console.log "(/slides/)(#{newData.id})(/img/#{file})"
                            pattern = new RegExp("(/slides/)#{oldSlideId}(/img/#{file})".replace(/\//g, '\/'))
                            console.log pattern
                            newData.markdown = newData.markdown.replace(pattern, "$1#{newData.id}$2")


                          writeData()
                  else
                    writeData()



                    console.log 'done'
                    # res.json req.body

                        # console.log exists
                    return


                # console.log newData



            # else

            # console.?log err
            # if err
            #   res.send 500, err
            #   return
            # console.?log err
            # console.log dirs

          # fs.readFile path.join(importPath, 'index.json'), 'utf8', (err, data) ->
          #   if err
          #     res.send 500, err
          #     return
          


      tar.stdin.end()





  # console.log file



exports.import()

  # res.json file

#   {
#     "fieldname": "file",
#     "originalname": "download (3).tar",
#     "name": "dcf457a25deccc714cf3daa9245b9743.tar",
#     "encoding": "7bit",
#     "mimetype": "application/x-tar",
#     "path": "/Users/naver/Sites/my-slide/server/.upload/dcf457a25deccc714cf3daa9245b9743.tar",
#     "extension": "tar",
#     "size": 296960,
#     "truncated": false,
#     "buffer": null
# }


    #   # path.join(slideRoot, req.params.id)

    # # parallels = []
    # slideImgPath = path.join(slidePath, req.params.id, 'img')
    # parallels.push (callback) ->
    #   # path.join(slidePath, req.params.id, file.originalname)
    #   mkdirp slideImgPath, (err) ->
    #     if err
    #       callback err
    #     else
    #       callback null
    # for file in files
    #   parallels.push ((file) ->
    #     (callback) ->
    #       srcPath = file.path
    #       dstPath = path.join(slideImgPath, file.originalname.replace(/\s+/g, '_'))
    #       src = fs.createReadStream(srcPath)
    #       dst = fs.createWriteStream(dstPath)
    #       src.pipe dst
    #       src.on 'end', ->
    #         callback null, file
    #       src.on 'error', (err) ->
    #         callback err
  
    #   )(file)

    # async.parallel parallels, (err, results) ->

    #   console.log results

    #   res.send 'ok'  