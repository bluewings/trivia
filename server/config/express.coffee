'use strict'

express = require('express')
fs = require('fs')
path = require('path')
favicon = require('serve-favicon')
morgan = require('morgan')
compression = require('compression')
bodyParser = require('body-parser')
methodOverride = require('method-override')
cookieParser = require('cookie-parser')
session = require('express-session')
errorHandler = require('errorhandler')
passport = require('passport')
mkdirp = require('mkdirp')
multer = require('multer')
config = require('./environment')

module.exports = (app) ->
  env = app.get('env')
  app.set 'views', config.root + '/server/views'
  app.set 'view engine', 'jade'
  app.locals.pretty = true

  # app.use(favicon());
  # app.use(logger('dev'));
  # app.use(bodyParser.json());
  # app.use(bodyParser.urlencoded());
  # app.use(cookieParser());
  # app.use(express.static(path.join(__dirname, 'public')));
  # app.use('/components', express.static(__dirname + '/bower_components'));
  # app.use(multer({
  #     dest: './_tmp/uploads/'
  # }));

  app.use compression()
  
  
  # app.use bodyParser.urlencoded()
  # app.use express.bodyParser(
  #   keepExtensions:true
  #   uploadDir:path.join(config.root, 'server', '.upload')

  # )
  app.use methodOverride()
  app.use cookieParser(config.secrets.session)
  app.use bodyParser.json()
  app.use bodyParser.urlencoded(extended: false)
  console.log '>>>>>>>> BODY PARSER'
  app.use session(
    secret: config.secrets.session
    resave: true
    saveUninitialized: true
  )
  app.use passport.initialize()
  app.use passport.session()

  uploadPath = path.join(config.root, 'server', '.upload')
  app.use multer(
    dest: uploadPath
  )

  if 'production' is env
    app.use favicon(path.join(config.root, 'public', 'favicon.ico'))
    app.use express['static'](path.join(config.root, 'public'))
    app.set 'appPath', config.root + '/public'
    app.use morgan('dev')
  if 'development' is env or 'test' is env
    app.use express['static'](path.join(config.root, '.tmp'))
    app.use express['static'](path.join(config.root, 'public'))
    app.set 'appPath', 'client'
    app.use morgan('dev')
    app.get '*', (req, res) ->
      console.log '>>>>>'
      indexFile = path.join(config.root, '.tmp', 'index.html')
      fs.createReadStream(indexFile).pipe(res)
      return
    app.use errorHandler()
  mkdirp uploadPath, (err) ->
    if err
      throw err
    else



