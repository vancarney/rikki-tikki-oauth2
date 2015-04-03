# fs              = require 'fs'
# (chai           = require 'chai').should()
# _               = (require 'underscore')._
# Backbone        = require 'backbone'
# Backbone.$      = require 'jQuery'
# {RikkiTikki}    = require '../index'
# jsonData        = require './data.json'
# server          = true
# API             = RikkiTikki.createScope 'api'
# API.PORT        = 3000
# 
# describe 'API.User lifecycle', ->
  # @timeout 15000
  # it 'Should create a new user', (done)=>
    # (@testUser = new API.User).save {username:'test.user',password:'sParseTest'},
      # success:(m,r,o)=>
        # done()
  # it 'Should be able to login', (done)=>
    # @testUser.login (@testUser.get 'username'), (@testUser.get 'password'),
      # success:(m,r,o)=>
        # done()
  # it 'Should have set SESSION_TOKEN after login', ->
    # API.SESSION_TOKEN.should.be.a 'string'
  # it 'Should be able to update itself', (done)=>
    # @testUser.save email: 'a.user+changed@email.com',
      # success:(m,r,o)=>
        # done()
      # error:(m,r,o)=>
        # console.log r
  # it 'Should be able to logout', (done)=>
    # @testUser.logout()
    # @testUser.save email: 'a.user@email.com',
      # error:(m,r,o)=>
        # done()
  # it 'Should be able to be destroyed', (done)=>
    # @testUser.login 'test.user', 'sParseTest',
      # success:(m,r,o)=>
        # @testUser.destroy 
          # success:(m,r,o)=>
            # done()