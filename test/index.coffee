Router            = require 'router'
global.API = require 'rikki-tikki'
global.Adapter    = require 'rikki-tikki-http-routes'
fs                = require 'fs'
path              = require 'path'
request           = require 'supertest'
OAuthModule       = require '../src'
(chai             = require 'chai').should()
global.app        = (require 'http').createServer()
global.host       = 'localhost'
global.port       = 3000


describe 'OAuth Test Suite', ->
  it 'should initialize',(done)=>
    @api = new API {adapter:Adapter.use app, new Router}, ((e, ok)=>
      return console.error "Could not start API service\n#{e}" if e?
    )
    @api.on 'open', => done()
    
    app.listen port, host

  it 'should register the Module', ->
    API.registerModule 'oauth', OAuthModule
    (API.retrieveModule 'oauth').should.be.a 'object'
    
  it 'should get Auth Request', (done)->
    request app
    .get "/#{OAuthModule.namespace}/authorize"
    # .expect 'Content-Type', /json/
    .end (e,res)=>
      # console.log res.body
      done()