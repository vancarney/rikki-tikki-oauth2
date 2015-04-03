Router            = require 'router'
global.API = require 'rikki-tikki'
global.Adapter    = require '../src/RoutesAdapter'
fs                = require 'fs'
path              = require 'path'
request           = require 'supertest'
(chai             = require 'chai').should()
global.app        = (require 'http').createServer()
global.host       = 'localhost'
global.port       = 3000


describe 'RoutesAdapter Test Suite', ->
  it 'should initialize',(done)=>
    @api = new API {adapter:Adapter.use app, new Router}, ((e, ok)=>
      return console.error "Could not start API service\n#{e}" if e?
    )
    @api.on 'open', => done()
    
    app.listen port, host
  # clazz = class Tester extends Adapter
  # describe 'RoutesAdapter Overrides', =>
    # it 'should require app to be passed in constructor params object', =>
      # chai.expect(-> 
        # new clazz()
      # ).to.throw 'required param \'router\' was not defined in the adapter params object'
  # describe 'RoutesAdapter Overrides', =>
    # it 'should require method requestHandler to be overriden', =>
      # chai.expect(-> 
        # (new clazz router:router).requestHandler {url:'/blargh'}
      # ).to.not.throw()
    # it 'should require method responseHandler to be overriden', =>
      # chai.expect(-> 
        # new clazz(router:{}).responseHandler {setHeader:(->false), writeHead:(->false), end:(->false)}, {status:200}
      # ).to.not.throw()
    # it 'should require method addRoute to be overriden', =>
      # chai.expect(-> 
        # new clazz(router:{match:((str)-> null), addRoute:((str)-> null)}).addRoute '/blargh','get', (->false)
      # ).to.not.throw()
      
  it 'should have defined a route', (done)=>
    API.addRoute '/test1', 'get', (req,res)->
      res.end JSON.stringify body:'ok'
    request app
    .get '/test1'
    .expect 200
    .end (e, r)=>
      return throw e if e?
      done()

  it 'should allow an API CREATE route', (done)=>
    request app
    .post '/api/1/item'
    .send { name: 'Manny', species: 'cat' }
    .expect 200
    .end (e, res)=>
      return throw e if e?
      done() if (@OBJ_ID = res.body._id)?

  it 'should allow an API READ route', (done)=>
    setTimeout (=>
      request app
      .get "/api/1/item/#{@OBJ_ID}"
      .expect 200
      .end (e, res)=>
        return throw e if e?
        done() if (res.body.name == 'Manny')
    ), 1500
      
  it 'should allow an API UPDATE route', (done)=>
    request app
    .put "/api/1/item/#{@OBJ_ID}"
    .send { name: 'Manuel', species: 'gato' }
    .end (e, res)=>
      return throw e if e?
      done()
      
  it 'should have updated the record', (done)=>
    request app
    .get "/api/1/item/#{@OBJ_ID}"
    .expect 200
    .end (e, res)=>
      return throw e if e?
      done() if (res.body.name == 'Manuel')
         
  it 'should allow an API DELETE route', (done)=>
    request app
    .del "/api/1/item/#{@OBJ_ID}"
    .expect 200, done
    
  it 'should have removed the record', (done)=>
    request app
    .get "/api/1/item/#{@OBJ_ID}"
    .expect 404
    .end (e, res)=>
      return throw e if e?
      done()