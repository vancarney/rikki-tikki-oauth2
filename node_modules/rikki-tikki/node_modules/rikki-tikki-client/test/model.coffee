fs              = require 'fs'
(chai           = require 'chai').should()
_               = (require 'underscore')._
Backbone        = require 'backbone'
Backbone.$      = require 'jQuery'
{RikkiTikki}    = require '../index'
jsonData        = require './data.json'
server          = true
API             = RikkiTikki.createScope 'api'
# API.API_VERSION = 'v1'
API.PORT        = 3000

# `  var wrapError = function(model, options) {
    # var error = options.error;
    # options.error = function(resp) {
      # if (error) error.call(options.context, model, resp, options);
      # model.trigger('error', model, resp, options);
    # };
  # };`
# 
# Backbone.Model::save = `function (key, val, options) {
      # var attrs, method, xhr, attributes = this.attributes;
      # if (key == null || typeof key === 'object') {
        # attrs = key;
        # options = val;
      # } else {
        # (attrs = {})[key] = val;
      # }
      # if (attrs && (!options || !options.wait) && !this.set(attrs, options)) return false;
#       
      # options = _.extend({validate: false}, options);
      # // Do not persist invalid models.
      # if (!this._validate(attrs, options)) return false;
# 
      # if (attrs && options.wait) {
        # this.attributes = _.extend({}, attributes, attrs);
      # }
# 
      # // After a successful server-side save, the client is (optionally)
      # // updated with the server-side state.
      # if (options.parse === void 0) options.parse = true;
      # var model = this;
      # var success = options.success;
      # options.success = function(resp) {
        # // Ensure attributes are restored during synchronous saves.
        # model.attributes = attributes;
        # var serverAttrs = model.parse(resp, options);
        # if (options.wait) serverAttrs = _.extend(attrs || {}, serverAttrs);
        # if (_.isObject(serverAttrs) && !model.set(serverAttrs, options)) {
          # return false;
        # }
        # if (success) success(model, resp, options);
        # model.trigger('sync', model, resp, options);
      # };
      # wrapError(this, options);
      # method = this.isNew() ? 'create' : (options.patch ? 'patch' : 'update');
      # if (method === 'patch') options.attrs = attrs;
      # xhr = this.sync(method, this, options);
# 
      # // Restore attributes.
      # if (attrs && options.wait) this.attributes = attributes;
#       
      # return xhr;
    # }`
# 
# console.log API.getAPIUrl()

# describe 'API.Model lifecycle', ->
  # it 'API.Model.saveAll should be STATIC', =>
    # API.Model.saveAll.should.be.a 'function'
  # it 'Model should be extensable', =>
    # (@clazz = class Test extends API.Model).should.be.a 'function'
  # it 'should safely get it\'s constructor.name', =>
    # (API.getConstructorName @testModel = new @clazz()).should.equal 'Test'
  # it 'should have a pluralized Class Name', =>
    # (@testModel).className.should.equal 'Tests'
  # it 'should save Data to an API Service', (done)=>
    # @timeout 15000
    # o = 
      # name:"A Test"
      # description: "Testing Object create via Rikki-Tikki API Client"
    # h = 
      # validate: false
      # success:(m,r,o)=>
        # done()
      # error:(m,r,o)=>
        # console.log arguments
        # throw 'done goofed'
    # @testModel.save o, h
  # it 'should have an ObjectID after saving', =>
    # (@testModel.get '_id').should.not.equal null
  # it 'should update Data to the API', (done)=>
    # @timeout 15000
    # o =
      # active:true
    # h = 
      # validate:false
      # success:(m,r,o)=>
        # done()
      # error:(m,r,o)=>
        # console.log arguments
        # throw 'done goofed'
    # @testModel.save o, h
  # it 'should delete it\'s self from the API DB', (done)=>
    # h = 
      # validate:false
      # success:(m,r,o)=>
        # done()
      # error:(m,r,o)=>
        # console.log arguments
        # throw 'done goofed'
    # @testModel.destroy h