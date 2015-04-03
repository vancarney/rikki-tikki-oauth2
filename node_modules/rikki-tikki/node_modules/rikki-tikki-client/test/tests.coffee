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

# if (typeof process.env.PARSE_APP_ID == 'undefined' or typeof process.env.PARSE_REST_KEY == 'undefined')
  # console.error 'Failure: PARSE_APP_ID and PARSE_REST_KEY are required to be set in your env vars to run tests'
  # process.exit 1

describe 'sParse Test Suite', ->
  it 'should exist', =>
    RikkiTikki.should.be.a 'object'
    # API.APP_ID   = process.env.PARSE_APP_ID
    # API.REST_KEY = process.env.PARSE_REST_KEY
  describe 'API Inflection', =>
    it 'should have PLURALIZATION', =>
      (API).Inflection.pluralize('Man').should.equal 'Men'
      (API).Inflection.pluralize('Person').should.not.equal 'Persons'
      (API).Inflection.pluralize('Person').should.equal 'People'
      (API).Inflection.pluralize('Ox').should.equal 'Oxen'
      (API).Inflection.pluralize('Mouse').should.equal 'Mice'
      (API).Inflection.pluralize('Deer').should.equal 'Deer'
      (API).Inflection.pluralize('Child').should.equal 'Children'
      (API).Inflection.pluralize('Life').should.equal 'Lives'
      (API).Inflection.pluralize('Lens').should.equal 'Lenses'
      (API).Inflection.pluralize('Mine').should.equal 'Mines'
      (API).Inflection.pluralize('Business').should.equal 'Businesses'
      (API).Inflection.pluralize('Octopus').should.equal 'Octopi' 