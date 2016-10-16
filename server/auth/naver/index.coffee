'use strict'

express = require('express')
passport = require('passport')
auth = require('../auth.service')
config = require('../../config/environment')

router = express.Router()

passport.serializeUser (user, done) ->
  done null, user
  return

passport.deserializeUser (user, done) ->
  done null, user
  return
request = require('request')


User =
  login: (provider, providerId, callback) ->
    request
      method: 'POST',
      uri: "http://10.101.63.27:8080/auth/#{provider}/#{providerId}/login"
    , (error, response, body) ->
      # console.log 'login'
      # console.log body
      unless error
        try
          body = JSON.parse(body)
        catch
          body = null
        if body
          #   body.user._id = body.user.userId
          #   body.user.customerId = body.customerId
          # console.log body
          callback? null, body
        else
          callback? new Error('User not found. 1')
      else
        callback? error
    return


# router.get('/', passport.authenticate('facebook',
#   scope: [
#     'email'
#     'user_about_me'
#   ]
#   failureRedirect: '/signup'
#   session: false
# )).get '/callback', passport.authenticate('facebook',
#   failureRedirect: '/signup'
#   session: false
# ), auth.setTokenCookie

# router.get '/', passport.authenticate 'naver', (err, user, naverProfile) ->


jwt = require('jsonwebtoken')


authenticate = (req, res, next) ->
  req.session.returnTo = req.headers.referer if req.session and req.headers.referer
  passport.authenticate('naver', (err, user, info) ->
    # naverProfile, accessToken) ->
    # console.log err
    console.log '>>> access token B'
    # console.log info.accessToken    
    console.log '>>>>>> B'
    console.log '\n\n\n'
    return next(err) if err
    console.log '>>>>>> C'
    console.log '\n\n\n'
    unless user
      # jwt =
      token = jwt.sign
        accessToken: info.accessToken
        profile: info.profile
        # customerId: user.customerId
        # saUserData:
        #   userId: user.userId
        #   userKey: user.userKey
      , config.secrets.session,
        expiresInMinutes: 30

      res.cookie 'signupToken', JSON.stringify(token)
      return res.redirect('/#/signup') unless user
    console.log '>>>>>> D'
    console.log '\n\n\n'
    # console.log naverProfile

    User.login 'naver', info.naverProfile.id
    , (error, body) ->
      # console.log body
      user.userKey = body.userKey
      console.log '>>>>>> E'
      console.log '\n\n\n'


      # 로그인 처리
      # req.login
      req.logIn user, (err) ->
        return next(err) if err
        auth.setTokenCookie req, res
        return







      next(err)
    # console.log '>>> err'
    # console.log err
    # console.log '>>> user'
    # console.log user
    # console.log '>>> naverUser'
    # console.log naverProfile
    # return res.redirect('/#/register') unless user

    # console.log user, info


    # req.logIn user, (err) ->
    #   return next(err) if err
    #   auth.setTokenCookie req, res
    #   return
    # return
  ) req, res, next
  return

router.get '/', authenticate
router.get '/callback', authenticate

module.exports = router
