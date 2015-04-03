fs              = require 'fs'
(chai           = require 'chai').should()
_               = (require 'underscore')._
Backbone        = require 'backbone'
Backbone.$      = require 'jQuery'
{RikkiTikki}    = require '../index'
jsonData        = require './data.json'
server          = true
API             = RikkiTikki.createScope 'api'
API.PORT        = 3000

# server          = true
# service          = require './scripts/server'

# if (typeof process.env.PARSE_APP_ID == 'undefined' or typeof process.env.PARSE_REST_KEY == 'undefined')
  # console.error 'Failure: PARSE_APP_ID and PARSE_REST_KEY are required to be set in your env vars to run tests'
  # process.exit 1
  
# RikkiTikki.APP_ID   = process.env.PARSE_APP_ID
# RikkiTikki.REST_KEY = process.env.PARSE_REST_KEY

# init data to test with
# test = RikkiTikki.createNameSpace 'test'
API.createSchema 'Products', {
  name:String
  price:Number
  description:String
}

clazz = class Products extends API.Collection 
# _.each require( './data/products.json' ).Products, (v,k)=>
  # model = new clazz
  # h = 
    # error:(m,r,o)->
      # console.log 'error'
  # model.save v, h
  


# describe 'RikkiTikki.Collections Test Suite', ->
  # it 'should have a pluralized Class Name', =>
    # (@testCol = new clazz).className.should.equal 'Products'
  # it 'should perform a GET', (done)=>
    # @testCol.fetch
      # success:(m,r,o)=>
        # done()
      # error:->
        # console.log arguments
  # it 'should perform a POST', (done)=>
    # @testCol.create {name:"Fantastic Rubber Computer", price:9},
      # success:(m,r,o)=>
        # done()
      # error:->
        # console.log arguments
  # it 'should perform a basic Query', (done)=>
    # @testCol.equalTo('name','Incredible Rubber Computer').fetch
      # success:(m,r,o)=>
        # done()
      # error:->
        # console.log arguments
  # it 'should perform a complex Query', (done)=>
    # # console.log RikkiTikki.Query.or @clazz.contains('name','Computer').greaterThanOrEqualTo('price',10)
    # q  = Products.contains('name','Computer').greaterThanOrEqualTo 'price', 5
    # # console.log q.query().toJSON()
    # q2 = Products.contains('name','Incredible').lessThanOrEqualTo('price',10).or q
    # console.log RikkiTikki.querify q2.__params
    # # console.log q2.query().toString()
    # Products.contains('name','Rubber').or(q2).fetch
      # success:(m,r,o)=>
        # console.log m
        # done()
      # error:->
        # console.log arguments
        
# describe 'API.Batch and API.Collections', ->
  # @timeout 15000
  # @data = new (class TestCompanies extends API.Collection
    # model: class TestCompany extends API.Object
      # defaults:
        # name:""
        # contact_email:""
        # tagline:""
  # )
  # @data.set jsonData.TestCompanies
  # @batch = new API.Batch
  # @batch.save @data.models
  # it 'Should Batch Save', (done)=>
    # @batch.exec
      # complete:(m,r,o)=>
        # done()
      # success:(m,r,o)=>
      # error:(m,r,o)=>
        # console.log m
  # it 'Should Query Records on the Server', (done)=>
    # @data.reset {}
    # @data.query active:true,
      # success:(m,r,o)=>
        # @data.models.length.should.equal 51
        # done()
  # it 'Should mark items for deletion', (done)=>
    # @data.reset {}
    # @data.fetch
      # success: (m,r,o)=>
        # @batch.destroy @data.models
        # done()
      # error: (m,r,o)=>
        # console.log r
  # it 'Should have a count of Records on the Server', =>
    # @data.count().should.equal 101
  # it 'Should Batch Delete', (done)=>
    # @batch.exec
      # complete:(m,r,o)=>
        # done()
      # error: (m,r,o)=>
        # console.log m
  # it 'Should have deleted all data records', (done)=>
    # @data.reset {}
    # @data.fetch
      # success: (m,r,o)=>
        # @data.count().should.equal 0
        # done()
      # error: (m,r,o)=>
        # console.log r
        
        
# # describe 'RikkiTikki.SchemaLoader Test Suite', ->
  # # @timeout 10000
  # it 'RikkiTikki should load Schemas', (done)=>
    # RikkiTikki.initialize {port:3006}, (e,res)=>
      # console.error e if e?
      # if res
        # RikkiTikki.getSchema('product').should.be.a 'Object'
        # #console.log RikkiTikki.getSchema('product') #.virtuals #.short_desc.should.be.a 'Function'
        # done()