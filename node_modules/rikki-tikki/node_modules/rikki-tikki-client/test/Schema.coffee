(chai           = require 'chai').should()
RikkiTikki      = require('../lib/rikki-tikki-client').RikkiTikki

describe 'RikkiTikki.Schema Test Suite', ->
  myNS = RikkiTikki.createScope 'myNS'
  it 'should have new scope', =>
    myNS.should.be.a 'object'
  it 'should create a new schema in the namespace', =>
    @schema = new myNS.Schema
      name:String
      description:String
      price:Number
      foo:
        type:Date
        default:Date.now
        illegal:true
        validators:[ ((value)-> typeof value == 'string'), 'must be string']
    @schema.should.be.a 'object'
    (@schema instanceof RikkiTikki.Schema).should.equal true
  it 'Schema should create paths', =>
    @schema.paths.name.path.should.equal 'name'
  it 'Schema should define an instance from a passed native Object', =>
    @schema.paths.name.instance.should.be.a 'function'
  it 'Schema should define an instance from a param type', =>
    @schema.paths.foo.instance.should.be.a 'function'
  it 'Schema should allow validators', =>
    @schema.paths.foo.validators.should.be.a 'Array'
    @schema.paths.foo.validators[0][0].should.be.a 'function'
  it 'Schema should filter out invalid params', =>
    @schema.paths.foo.should.not.have.property 'illegal'