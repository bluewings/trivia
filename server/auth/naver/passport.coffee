'use strict'

passport = require('passport')
NaverStrategy = require('passport-naver').Strategy
request = require('request')

User =
  findByProviderId: (provider, providerId, callback) ->
    request
      method: 'GET',
      uri: "http://10.101.63.27:8080/auth/#{provider}/#{providerId}"
    , (error, response, body) ->
      unless error
        try
          body = JSON.parse(body)
        catch
          body = null
        if body && body.user
          body.user._id = body.user.userId
          body.user.customerId = body.customerId
          callback? null, body.user
        else
          callback? null, null
      else
        callback? error
    return
  login: (provider, providerId, callback) ->
    request
      method: 'POST',
      uri: "http://10.101.63.27:8080/auth/#{provider}/#{providerId}/login"
    , (error, response, body) ->
      # console.log 'login'
      # console.log response
      unless error
        try
          body = JSON.parse(body)
        catch
          body = null
        if body
          body.user._id = body.user.userId
          body.user.customerId = body.customerId
          console.log response
          callback? null, body.user
        else
          callback? new Error('User not found. 3')
      else
        callback? error
    return

exports.setup = (User1, config) ->
  passport.use new NaverStrategy(
    clientID: config.naver.clientID
    clientSecret: config.naver.clientSecret
    callbackURL: config.naver.callbackURL
  , (accessToken, refreshToken, profile, done) ->
    console.log '>>> access token'
    console.log accessToken
    console.log ''
    console.log ''
    User.findByProviderId 'naver', profile.id
    , (err, user) ->
      console.log '>>>>>> A'
      console.log '\n\n\n'
      return done(err) if err
      done(new Error('Not registered yet.')) unless user
      console.log '>>> BEFORE SENT'
      console.log accessToken
      console.log ''
      console.log ''
      done err, user,
        profile: profile
        accessToken: accessToken
      return
    return
  )
  return