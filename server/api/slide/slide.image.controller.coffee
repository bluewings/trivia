"use strict"

fs = require("fs")
path = require("path")
async = require("async")
rmdir = require('rimraf')
mkdirp = require('mkdirp')

# slideRoot = path.join(__dirname, "..", "..", "..", "public", "slides")
# uid = ->
#   (parseInt(Math.random() * 900000000 + 100000000, 10)).toString(36).substr 0, 6

# prepare = ->
#   fs.exists slideRoot, (exists) ->
#     unless exists
#       fs.mkdir slideRoot, (err) ->
#         throw err  if err and (err and err.code isnt "EEXIST")
#         return

#     return

#   return

# prepare()
uploadPath = path.join(__dirname, '..', "..", ".upload")
slidePath = path.join(__dirname, '..', "..", '..', 'public', "slides")


exports.index = (req, res) ->


  slideImgPath = path.join(slidePath, req.params.id, 'img')
  fs.exists slideImgPath, (exists) ->
    unless exists
      res.json []
    else
      fs.readdir slideImgPath, (err, files) ->
        # if err
        if err
          res.json 500, err
          return
        for file, i in files
          files[i] = "/slides/#{req.params.id}/img/#{file}"
        res.json files         
# console.log uploadPath

# router.post "/:id/images", (req, res) ->
exports.create = (req, res, next) ->
  # libPath = path.join(__dirname, "..", "lib", "markupguide.jar")
  # workId = uid()
  # uploadPath = path.join(uploadPath, "uploads")

  # console.log req.files

  if !req.files or !req.files.file
    console.log 'err'
  else
    if Array.isArray req.files.file
      files = req.files.file
    else
      files = [req.files.file]



    parallels = []
    slideImgPath = path.join(slidePath, req.params.id, 'img')
    parallels.push (callback) ->
      # path.join(slidePath, req.params.id, file.originalname)
      mkdirp slideImgPath, (err) ->
        if err
          callback err
        else
          callback null
    for file in files
      parallels.push ((file) ->
        (callback) ->
          srcPath = file.path
          dstPath = path.join(slideImgPath, file.originalname.replace(/\s+/g, '_'))
          src = fs.createReadStream(srcPath)
          dst = fs.createWriteStream(dstPath)
          src.pipe dst
          src.on 'end', ->
            callback null, file
          src.on 'error', (err) ->
            callback err
  
      )(file)

    async.parallel parallels, (err, results) ->

      console.log results

      res.send 'ok'

  return
  dstFolder = path.join(__dirname, "..", "public", "uploads", req.params.id)
  # srcPath = path.join(uploadPath, req.files.file.name)
  dstPath = path.join(slidePath, req.params.id, req.files.file.name)
  fs.mkdir dstFolder, (err) ->
    src = fs.createReadStream(srcPath)
    dst = fs.createWriteStream(dstPath)
    src.pipe dst
    src.on "end", ->
      cmd = "java -jar " + libPath + " " + dstPath
      fs.unlink srcPath
      exec cmd, (err, stdout, stderr) ->
        if err
          res.jsonp
            status: ERROR
            message: err

        else
          setTimeout (->
            gmInst = gm(path.join(path.join(dstFolder, workId + ".png"))).autoOrient()
            gmInst.size (err, source) ->
              res.jsonp
                status: SUCCESS
                data:
                  workId: workId
                  name: req.files.file.originalname.replace(/\.psd$/, "")
                  fileName: req.files.file.originalname
                  fileSize: req.files.file.size
                  filePath: "/uploads/" + req.params.id + "/"
                  mimetype: req.files.file.mimetype
                  width: source.width
                  height: source.height

              return

            return
          ), 300
        return

      return

    src.on "error", (err) ->
      fs.unlink srcPath
      res.jsonp
        status: ERROR
        message: err

      return

    return

  return


exports.destroy = (req, res) ->

  # slidePath = path.join slideRoot, req.params.id
  # console.log slidePath
  # console.log req.params

  targetFile = path.join(slidePath, req.params.id, 'img', req.params.image)

  fs.unlink targetFile, (err) ->


    if err
      res.json 500, err
    else
      res.send 204
    return

  # rmdir slidePath, (err) ->
  #   return res.send(500, err)  if err

  #   res.send 204
  # return
  # # rmdir
  # User.findByIdAndRemove req.params.id, (err, user) ->
  #   return res.send(500, err)  if err
  #   res.send 204

  return  
