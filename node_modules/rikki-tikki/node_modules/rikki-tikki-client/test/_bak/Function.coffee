(chai           = require 'chai').should()
test = (RikkiTikki     = require('../index').RikkiTikki).createScope 'test'

describe 'RikkiTikki.Function Test Suite', ->
  it 'should create a function from a string', =>
    test.Function.fromString("function(){ return 'success'; }")().should.equal 'success'
    test.Function.fromString('Native::Date').should.equal Date
  it 'should stringify native and user functions', =>
    test.Function.toString((-> return true)).should.be.a 'string'
    test.Function.toString(Date).should.equal 'Native::Date'
    
    
