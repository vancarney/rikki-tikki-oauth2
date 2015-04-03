#### $scope.Object
# > Represents a single Record Association
class $scope.Object extends Backbone.Model
  #### idAttribute
  # > maps our Backbone.Model id attribute to the Api's _id attribute
  idAttribute: '_id'
  __schema:{paths:{}, virtuals:{}}
  createOptions:(options)->
    success = options.success || null
    _.extend options, {
      success:(m,r,o)=>
        $scope.SESSION_TOKEN  = r.session_id
        $scope.CSRF_TOKEN     = r.csrf_token
        $scope.USER_EMAIL     = r.user_email
        $scope.USER_TOKEN     = r.user_token
        success?.apply @, arguments
    }
  #### constructor(attrs, opts)
  # > Class Constructor Method
  constructor:(attrs={}, opts={})->
    # passes `arguments` to __super__
    super attrs, opts
    # writes warning to console if the Object's `className` was not detected
    if (@className ?= $scope.getConstructorName @) == $scope.UNDEFINED_CLASSNAME
      console.warn "#{namespace}.Object requires className to be defined"
    # pluralizes the `className`
    else
      @className = $scope.Inflection.pluralize @className
    @setSchema _.extend $scope.getSchema( @className ) || @__schema, opts.schema || {}
  setSchema:(schema)->
    @__schema = _.extend @__schema, schema
    if (methods = @__schema.methods)?
      _.each methods, (v,k)=> @[k] = ()=> v.apply @, arguments
    if (virtuals = @__schema.virtuals)?
      _.each virtuals, (v,k)=> 
        @[k] = $scope.Function.fromString v
        # console.log @[k]
    if (statics = @__schema.statics)?
      _.each statics, (v,k)=> $scope.Object[k] = $scope.Function.fromString v
    if @__schema.paths?
      _.each @__schema.paths, (v,k)=> (@defaults ?= {})[k] = v.default || null
  getSchema:-> @__schema
  validate:(attrs={}, opts={})->
    if $scope.env != 'development'
      for k,v of attrs
        if (path = @getSchema().paths[ k ])?
          for validator in path.validators || []
            return validator[1] if (validator[0] v) == false
        else
          return "#{@className} has no attribute '#{k}'" if k != @idAttribute
    return
  #### url() 
  # > generates an API URL for this object based on the Class name
  url : ->
    base    = $scope.getAPIUrl()
    ref     = unless $scope.CAPITALIZE_CLASSNAMES then @className.toLowerCase() else @className
    item    = unless @isNew() then "/#{@get @idAttribute}" else ''
    search  = if (p=$scope.querify @__op).length then "?#{p}" else ''
    "#{base}/#{ref}#{item}#{search}"
  #### sync(method, model, [options])
  # > Overrides `Backbone.Model.sync` to apply custom API header and data
  sync : (method, model, options={})->
    # obtains new API Header Object
    opts = $scope.apiOPTS()
    
    encode = (o)->
      if _.isObject o and o.hasOwnProperty '_toPointer' and typeof o._toPointer == 'function' 
        o = o._toPointer()
      o
      
    if method.match /^(create|read)+$/
      _.each model.attributes, (v,k)=>
        v = encode v if _.isObject v
        if _.isArray v
          _.map v, (o) => if _.isObject then encode o else o
    # sets the encoded request data to request header
    opts.data = if !@_query then JSON.stringify @.toJSON() else "where=#{@_query.toJSON()}"
    # sets `options.url` to avoid duplicate test in `__super__.sync`
    $scope.validateRoute options.url ?= _.result(@, 'url') || '/'
    
    # calls `sync` on __super__
    Object.__super__.sync.call @, method, model, _.extend( options, opts )
  #### get(attribute)
  # > Overrides `Backbone.Model.get`
  get:(attr)->
    if @__schema.virtuals[attr]
      value = (if _.isArray (v = @__schema.virtuals[attr]) then v else [v]).reduce (prev,curr,idx,arr)=> curr.apply @
    else
      value = Object.__super__.get.call @, attr
    value
  #### set(attributes, [options])
  # > Overrides `Backbone.Model.set`
  set:(attrs, opts={})->
    if attrs? and _.isObject attrs
      _.each attrs, (v,k)=>
        if @__schema.virtuals[k]
          attr = (if _.isArray (v = @__schema.virtuals[k]) then v else [v]).reduce (prev,curr,idx,arr)=> curr.apply @, value 
        else
          if v?.hasOwnProperty '_toPointer' and typeof v._toPointer == 'Function'
            v = v._toPointer() 
            if (oV = @get k )?.__op?
              (oV.objects ?= []).push v
            else
              k:{__op:"AddRelation", objects:[v]}
    # attrs = $scope._encode attrs
    s = Object.__super__.set.call @, attrs, opts
    # sets `__isDirty` to true if attributes have changed
    @__isDirty = true if @changedAttributes()
    s
  #### save(attributes, [options])
  # > Overrides `Backbone.Model.save`
  save:(attributes, options={})->
    self = @
    $scope.Object._findUnsavedChildren @attributes, children = [], files = []
    pre.save?() if (pre = @getSchema().pre)?
    if children.length
      $scope.Object.saveAll children,
        completed: (m,r,o) =>
          if m.responseText? and (rt = JSON.parse m.responseText) instanceof Array
            _.each @attributes, (v,k)=>
              if v instanceof $scope.Object and v.get?( 'objectId' ) == rt[0].success.objectId
                # console.log p = v._toPointer()
                @attributes[k] = {__op:"AddRelation", objects:[p]} 
          Object.__super__.save.call self, attributes, 
            success: => 
              options.completed? m,r,o
            error: -> console.log 'save failed'
          
        success: (m,r,o) =>
          post.save?() if (post = @getSchema().post)?
          options.success? m,r,o
        error:   (m,r,o) => options.error? m,r,o
    else
      # calls `save` on __super__
      Object.__super__.save.call @, attributes, options
  #### toJSON([options])
  # > Overrides `Backbone.Model.toJSON`
  toJSON : (options)->
    # calls `toJSON` on __super__
    data = (Object.__super__.toJSON.call @, options) || {}
    # cleans the object
    delete data.createdAt if data.createdAt?
    delete data.updatedAt if data.updatedAt?
    data
  #### toFullJSON(seenObjects)
  # > Encodes Object to Parse formatted JSON object
  _toFullJSON: (seenObjects)->
    # loops on `_.clone` of Object attributes and applies `$scope._encodes`
    _.each (json = _.clone @attributes), (v, k) -> json[key] = $scope._encode v, seenObjects
    # loops on `__op` and sets to JSON object
    _.each @__op, (v, k) -> json[v] = k
    # sets `objectId` from `id`
    json.objectId  = @id if _.has @, 'id'
    # sets `createdAt` from attributes
    json.createdAt = (if _.isDate @createdAt then @createdAt.toJSON() else @createdAt) if _.has @, 'createdAt'
    # sets `updatedAt` from attributes
    json.updatedAt = (if _.isDate @updatedAt then @updatedAt.toJSON() else @updatedAt) if _.has @, 'updatedAt'
    # sets `__type` to Object
    json.__type    = 'Object'
    # sets `className` from Object properties
    json.className = @className
    # returns the JSON object
    json
  #### nestCollection(attributeName, collection)
  nestCollection: (aName, nCollection) ->
    # setup nested references
    for item, i in nCollection
      @attributes[aName][i] = (nCollection.at i).attributes
    # create empty arrays if none
    nCollection.bind 'add', (initiative) =>
      if !@get aName
        @attributes[aName] = []
      (@get aName).push initiative.attributes
    # remove arrays
    nCollection.bind 'remove', (initiative) =>
      updateObj = {}
      updateObj[aName] = _.without (@get aName), initiative.attributes 
      @set updateObj
    # return
    nCollection
  #### __op
  # > Holder for Object operations
  __op: null
  #### _serverData
  # > holder for data as last fetched from server
  _serverData:{}
  #### _opSetQueue
  # > Holder for Object operations Queue
  _opSetQueue: [{}]
  #### __isDirty
  # > indicates if any attribute has changed since last save
  __isDirty:false
  #### dirty()
  # > returns true if Object `attributes` have changed
  dirty:->
    @__isDirty or @hasChanged()
  #### _toPointer()
  # > Returns a `Pointer` reference of this `Object` for use by `$scope._encode`
  _toPointer: ->
    # throws an error if we try to get a`Pointer` of an item with no id
    throw new Error "Can't serialize an unsaved #{namespace}.Object" if @isNew()
    # returns the pointer
    __type: 'Pointer'
    className: @className
    objectId: @id
  #### _finishFetch(serverData, hasData)
  # > Cleans up Object properties
  _finishFetch: (serverData, hasData)->
    # resets `_opSetQueue`
    @_opSetQueue = [{}]
    # handles special attributes
    @_mergeMagicFields serverData
    # decodes `serverData`
    _.each serverData, (v, k) => @_serverData[key] = $scope._decode k, v
    # stores `hasData` to object scope
    @_hasData = hasData
    # resets `__isDirty`
    @__isDirty = false
  #### _mergeMagicFields(attrs)
  # > Returns a `Pointer` reference of this `Object` for use by `$scope._encode`
  _mergeMagicFields: (attrs)->
    # loops through field names
    _.each ['id', 'objectId', 'createdAt', 'updatedAt'], (attr)=>
        if attrs[attr]
          # switches on existing attributes
          switch attrs[attr]
            # handles `objectId`
            when 'objectId'
              @id = attrs[attr] 
            # handles `createdAt` and `updatedAt`
            when 'createdAt', 'updatedAt'
              @[attr] = if !_.isDate attrs[attr] then $scope._parseDate attrs[attr] else attrs[attr]
          # deletes the attribute
          delete attrs[attr]
          
  ## Atomic Operations
  # > Parse API Operation Methods
  #
         
          
  #### add(attr, object)
  # > Concats passed objects to an Array attribute
  add:(attr, objects)->
    # tests for array and applies `concat`
    @set (({})[attr] = a.concat objects), null if _.isArray (a = @get 'attr')
    # returns changedAttributes object
    @changedAttributes()
  #### addUnique(attr, object)
  # > Uniquely adds passed objects to an Array attribute
  addUnique:(attr, objects)->
    # tests for array and applies `_.union`
    @set (({})[attr] = _.union a, objects), null if _.isArray (a = @get 'attr')
    # returns changedAttributes object
    @changedAttributes()
  #### increment(attr, amount)
  # > Increments a Number to the passed value or by 1
  increment: (attr, amount)->
    # tests for Number and adds given value
    @set ({})[attr] = a + (amount ?= 1), null if _.isNumber (a = @get 'attr')
    # returns changedAttributes object
    @changedAttributes()
  addRelation:(key,relation)->
    (@__op ?= new $scope.OP @).addRelation key, relation
  removeRelation:(key,relation)->
    (@__op ?= new $scope.OP @).removeRelation key, relation    
  createRelation:(key)->
    (@__op ?= new $scope.OP @).relation key 
  relation:(key)->
    @createRelation key    
          
          
## Static Methods
# > Parse API helper methods
#
          
          
#### $scope.Object._classMap
# > holder for user defined $scope.Objects
$scope.Object._classMap    = {}
#### $scope.Object._getSubclass
# > returns reference to user defined `$scope.Object` if `className` can be addressed
$scope.Object._getSubclass = (className)->
  # throws error if className is not a string
  throw "#{namespace}.Object._getSubclass requires a string argument." unless _.isString className
  # sets className on `$scope.Object._classMap` if new and returns Class 
  $scope.Object._classMap[className] ?= if (clazz = $scope.Object._classMap[className]) then clazz else $scope.Object.extend className
#### $scope.Object._findUnsavedChildren
$scope.Object._findUnsavedChildren = (object, children, files)->
  _.each object, (obj)=>
    if (obj instanceof $scope.Object)
      children.push obj if obj.dirty()
      return
    # if (object instanceof $scope.File)
      # files.push obj if !obj.url()
      # return
#### $scope.Object._create
# > Creates an instance of a subclass of $scope.Object for the given classname
$scope.Object._create = (className, attr, opts)->
  # tests for existing Class as Function
  if typeof (clazz = $scope.Object._getSubclass className) is 'function'
    # returns the found class
    return new clazz attr, opts
  else
    # throws error if no class was found
    throw "unable to create #{className}"
#### $scope.Object.saveAll
# > Batch saves a given list of $scope.Objects
$scope.Object.saveAll = (list, options)->
  # create new `$scope.Batch` with the passed list
  (new $scope.Batch list
  ).exec
    # calls `Batch.exec` with callbacks
    success:(m,r,o)=>
      options.success m,r,o if options.success
    completed:(m,r,o)=>
      options.completed m,r,o if options.completed
    error:(m,r,o)=>
      options.error m,r,o if options.error
#### $scope.Object.destroyAll
# > Batch destroys a given list of $scope.Objects
$scope.Object.destroyAll = (list, options)->
  # create new `$scope.Batch` with the passed list
  (new $scope.Batch
  ).destroy list, 
    # calls `Batch.destroy` with callbacks
    success:(m,r,o)=>
      options.success m,r,o if options.success
    complete:(m,r,o)=>
      options.complete m,r,o if options.complete
    error:(m,r,o)=>
      options.error m,r,o if options.error