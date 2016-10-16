'use strict'

module.exports = (app) ->

  # Insert routes below
  # app.use '/api/creatives', require('./api/creative')
  # app.use '/api/slides', require('./api/slide')
  app.use '/auth', require('./auth')
  app.use '/translation', require('./api/translation')
  app.use '/feedback', require('./api/feedback')

  return
