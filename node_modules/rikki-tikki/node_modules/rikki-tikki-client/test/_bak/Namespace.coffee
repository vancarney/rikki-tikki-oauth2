(chai           = require 'chai').should()
RikkiTikki      = require('../index').RikkiTikki

describe 'Namespace Test Suite', ->
  @Client = RikkiTikki.createScope( 'Client' );
  it 'should segregate Namespace',=>
    @Client.NAMESPACE.should.equal 'Client'
    new @Client.Object()
