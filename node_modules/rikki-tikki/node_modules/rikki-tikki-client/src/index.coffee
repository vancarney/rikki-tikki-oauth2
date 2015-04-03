#### global
# > References the root environment RikkiTikki is operating in
global = exports ? window
# Includes Backbone & Underscore if the environment is NodeJS
_           = global._ || unless typeof exports is 'undefined' then require 'lodash' else null
Backbone    = global.Backbone || unless typeof exports is 'undefined' then require 'backbone' else null
Backbone.$  = global.jQuery || unless typeof exports is 'undefined' then require 'jQuery' else null
unless global.RikkiTikki
  #### global.RikkiTikki
  # > Defines the `RikkiTikki` namespace in the 'global' environment
  RikkiTikki = global.RikkiTikki = (->
    _appLayer = (ns)->
      throw "Namespace required to be type 'String'. Type was '<#{type}>'" unless (type = typeof ns) is 'string'
      $scope = global["#{ns}"] =
        #### __SCHEMAS__
        #> Placeholder for Schemas
        __SCHEMAS__: {}
        ALLOWED: ['APP_ID', 'REST_KEY', 'HOST', 'PORT', 'BASE_PATH', 'MAX_BATCH_SIZE', 'DEFAULT_FETCH_LIMIT_OVERRIDE', 'UNDEFINED_CLASSNAME']
        #### VERSION
        # > The current RikkiTikki Version Number
        VERSION:'0.1.1-alpha'
        #### APP_ID 
        # > The Parse API Application Identifier
        APP_ID:undefined
        APP_ID_PARAM_NAME:'APP_ID'
        #### REST_KEY 
        # > The Parse API REST Access Key
        REST_KEY:undefined
        REST_KEY_PARAM_NAME:'REST_KEY'
        #### SESSION_TOKEN
        # > The User's Session Token if signed in
        SESSION_TOKEN:undefined
        #### SESSION_TOKEN
        # > The User's CSRF Authentication Token for anti-forgery
        CSRF_TOKEN:undefined
        #### API_VERSION
        # The supported Parse API Version Number
        API_VERSION:'1'
        #### MAX_BATCH_SIZE
        # > The `RikkiTikki.Batch `request object length 
        # Can be set to -1 to disable sub-batching
        # >   
        # **Note**: Changing this may cause `RikkiTikki.Batch` requests to fail
        MAX_BATCH_SIZE:50
        #### DEFAULT_FETCH_LIMIT_OVERRIDE
        # > Stores maximum number of records to retrieve in a `fetch` operation.
        # >  
        # **Note**: Parse limits fetch requests to 100 records and provides no pagination. To circumvent this, we override the Fetch Limit to attempt to pull all records set this to a lower or higher amount to suit your needs
        # >
        # **See also**: REST API Queries
        DEFAULT_FETCH_LIMIT_OVERRIDE: 200000
        #### UNDEFINED_CLASSNAME
        # > Default ClassName to use for Models and Collections if none provided or detected
        UNDEFINED_CLASSNAME:'__UNDEFINED_CLASSNAME__'
        #### API_URI
        # > Base URI for the Parse API
        API_URI:null
        CORS:true
        PROTOCOL: 'HTTP'
        HOST:'0.0.0.0'
        PORT: 80
        BASE_PATH:'/api'
        CAPITALIZE_CLASSNAMES:false
        #### CRUD_METHODS
        # > Mappings from CRUD to REST
        CRUD_METHODS:
          create: 'POST'
          read:   'GET'
          update: 'PUT'
          destroy:'DELETE'
        getSchema: (name)->
          if (s = @__SCHEMAS__[name])? then s else null
        createSchema: (name, options={})->
          if (s = @getSchema name)? then _.extend s, options else $scope.__SCHEMAS__[name] = new @Schema options
        extend:(object)->
          _.extend @, object
      '{{classes}}'
      # $scope.schemaLoader: new $scope.SchemaLoader namespace: ns
      # .fetch 
        # success:  => callback? null, 'ready'
        # error:    => callback? 'failed', null
      $scope
    app = 
      createScope: (ns, schema={})->
        return global[ns] if global[ns]
        _.extend new _appLayer(ns), {namespace:ns, schema:schema}
      # RikkiTikki.createCollection = (name, options={})->
        # new (RikkiTikki.Collection.extend options, className:name)
      initialize: (opts={}, callback)->
        _.each opts, (value, key) =>
          key = key.toUpperCase()
          if 0 <= @ALLOWED.indexOf key
            @[key] = value
          else
            throw "option: '#{key}' was not settable"
  )()