(chai           = require 'chai').should()
RikkiTikki      = require('../lib/rikki-tikki-client').RikkiTikki

# class FooClass 

describe 'RikkiTikki.$scope Test Suite', ->
  it 'should create a scope', ->
    (@scope = RikkiTikki.createScope 'test', foo: bar: 'baz').schema.foo.should.be.a 'object'

