fs                = require 'fs'
path              = require 'path'
(chai             = require 'chai').should()
Adapter           = require '../src/AbstractRouteAdapter'

describe 'AbstractRouteAdapter Test Suite', ->
  clazz = class Tester extends Adapter
  describe 'AbstractRouteAdapter Overrides', =>
    it 'should require method requestHandler to be overriden', =>
      chai.expect(-> 
        new clazz().requestHandler()
      ).to.throw 'AbstractRouteAdapter.requestHandler(req,res) must be implemented by subclass'
    it 'should require method responseHandler to be overriden', =>
      chai.expect(-> 
        new clazz().responseHandler()
      ).to.throw 'AbstractRouteAdapter.responseHandler(req,res) must be implemented by subclass'
    it 'should require method addRoute to be overriden', =>
      chai.expect(-> 
        new clazz().addRoute()
      ).to.throw 'AbstractRouteAdapter.addRoute(route, method, handler) must be implemented by subclass'

