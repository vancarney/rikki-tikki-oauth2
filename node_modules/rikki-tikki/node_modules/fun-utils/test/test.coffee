(chai = require 'chai').should()
{Fun} = require '../src/fun-utils'
class Funct
  constructor:->
describe 'Fun-Utils Tests', ->
  @fun = (foo,bar)-> console.log "#{foo} #{bar}"
  it 'should stringify a function', =>
    (@str = Fun.toString( @fun )).replace(/[\n\t]*/g, '').replace(/[\s]{2,}/g,' ').should.equal 'function (foo, bar) { return console.log("" + foo + " " + bar); }'
  it 'should revive a function from a string', =>
    Fun.fromString(@str).should.be.a 'function'
  it 'should encode a Native Object', =>
    Fun.toString(Date).should.equal 'Native::Date'
  it 'should create a Native Object from reference', =>
    Fun.fromString('Native::Date').should.equal Date
  it 'should get the constructor name',=>
    Fun.getConstructorName(new Funct).should.equal 'Funct'
  it 'should get a function name',=>
    f = `function testing() {}`
    Fun.getFunctionName(f).should.equal 'testing'
  it 'should exec a Constructor', =>
    (Fun.construct( Date, '5/Nov/1605' )).toString().should.equal 'Sat Nov 05 1605 00:00:00 GMT-0700 (PDT)'
  it 'should create and exec a Function', =>
    (Fun.factory ['a,b', 'return a + b'])(2,2).should.equal 4
