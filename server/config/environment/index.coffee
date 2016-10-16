'use strict'

_ = require('lodash')
path = require('path')

# All configurations will extend these options
# ============================================
all =
  env: process.env.NODE_ENV

  # Root path of server
  root: path.normalize(__dirname + '/../../..')

  # Server port
  port: process.env.PORT or 9000

  # Should we populate the DB with sample data?
  seedDB: false

  # Secret for session, you will want to change this and make it an environment variable
  secrets:
    session: 'steve-rogers'

  # List of user roles
  userRoles: [
    'guest'
    'user'
    'admin'
  ]

  # MongoDB connection options
  mongo:
    options:
      db:
        safe: true

  naver:
    clientID: process.env.NAVER_ID or 'I5jVQGMtfEqw6gI_FkKy'
    clientSecret: process.env.NAVER_SECRET or 'sXTD9us0cj'
    callbackURL: (process.env.DOMAIN or '') + '/auth/naver/callback'

  facebook:
    clientID: process.env.FACEBOOK_ID or 'DEFAULT_FACEBOOK_ID'
    clientSecret: process.env.FACEBOOK_SECRET or 'DEFAULT_FACEBOOK_SECRET'
    callbackURL: (process.env.DOMAIN or '') + '/auth/facebook/callback'

  google:
    clientID: process.env.GOOGLE_ID or 'DEFAULT_GOOGLE_ID'
    clientSecret: process.env.GOOGLE_SECRET or 'DEFAULT_GOOGLE_SECRET'
    callbackURL: (process.env.DOMAIN or '') + '/auth/google/callback'

# Export the config object based on the NODE_ENV
# ==============================================
# module.exports = _.merge(all, require('./' + process.env.NODE_ENV + '.js') or {})
module.exports = _.merge(all, require('./' + process.env.NODE_ENV) or {})
