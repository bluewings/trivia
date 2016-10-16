'use strict'

express = require('express')
passport = require('passport')
config = require('../config/environment')
# User = require('../api/user/user.model')

# Passport Configuration
# require('./facebook/passport').setup User, config
require('./naver/passport').setup {}, config
# require('./google/passport').setup User, config

router = express.Router()

# router.use '/facebook', require('./facebook')
router.use '/naver', require('./naver')
# router.use '/google', require('./google')

router.get '/', (req, res) ->
  # console.log req.user
  res.end()

module.exports = router
