#### $scope.apiOPTS
# > Generates a Parse compatible API Header
$scope.apiOPTS = ->
  o = 
    contentType: "application/json"
    processData: false
    dataType: 'json'
    data: null
    headers:
      'Content-Type'      : 'application/json'
      'X-Application-Id'  : $scope.APP_ID
      'X-REST-API-Key'    : $scope.REST_KEY
      'X-Session-Token'   : $scope.SESSION_TOKEN
      'X-CSRF-Token'      : $scope.CSRF_TOKEN
      'X-User-Token'      : $scope.USER_TOKEN
      'X-User-Email'      : $scope.USER_EMAIL
#### $scope.regEscape(string)
# > Returns string as RegExp string literal
$scope.regEscape = (string) -> string.replace /([\^\/\.\-\+\*\[\]\{\}\|\(\)\?\$]+)/g,'\\$1'
$scope.getAPIUrl = ->
  "#{@PROTOCOL.toLowerCase()}://#{@HOST}#{if @PORT != 80 then ':'+@PORT else ''}/#{@BASE_PATH.replace /^\//, ''}/#{@API_VERSION}"
#### $scope.validateRoute(route)
# > Validates a given route
$scope.validateRoute = (route)->
  # throws error if route does not pass validation
  throw "Bad route: #{route}" if !route.match new RegExp "^(#{$scope.regEscape @getAPIUrl()}\/)+"
  # returns true if no error thrown
  true
#### $scope._parseDate(iso8601)
# > Implementation of Parse._parseDate used to parse iso8601 UTC formatted `datetime`
$scope._parseDate = (iso8601)->
  # returns null if `iso8601` argument fails `RegExp`
  return null if (t = iso8601.match /^([0-9]{1,4})\-([0-9]{1,2})\-([0-9]{1,2})T+([0-9]{1,2}):+([0-9]{1,2}):?([0-9]{1,2})?(.([0-9]+))?Z+$/) == null
  # returns new `Date` from matched value
  new Date Date.UTC t[1] || 0, (t[2] || 1) - 1, t[3] || 0, t[4] || 0, t[5] || 0, t[6] || 0, t[8] || 0
#### $scope.querify(object)
# > Returns passes object as Key/Value paired string
$scope.querify = (obj)->
  ( _.map _.pairs( obj || {} ), (v,k)=>v.join '=' ).join '&'
#### $scope.getConstructorName
# > Attempts to safely determine name of the Class Constructor returns $scope.UNDEFINED_CLASSNAME as fallback
$scope.getConstructorName = (fun)->
  fun.constructor.name || if (name = $scope.getFunctionName fun.constructor)? then name else $scope.UNDEFINED_CLASSNAME
$scope.getTypeOf = (obj)-> Object.prototype.toString.call(obj).slice 8, -1
$scope.getFunctionName = (fun)->
  if (n = fun.toString().match /function+\s{1,}([a-zA-Z]{1,}[_0-9a-zA-Z]?)/)? then n[1] else null
$scope.isOfType = (value, kind)->
  (@getTypeOf value) == (@getFunctionName kind) or value instanceof kind
#### $scope._encode
# > Attempts to JSON encode a given Object
$scope._encode = (value, seenObjects, disallowObjects)->
  # throws error if $scope.Model is passed while disallowed
  throw "$scope.Models not allowed here" if value instanceof $scope.Model and disallowObjects 
  # returns pointer value
  return value._toPointer() if value instanceof $scope.Object and value._toPointer? and typeof value._toPointer == 'function' #!seenObjects or _.include(seenObjects, value) or value.attributes != value.defaults
  # returns encoded $scope.Model
  return $scope._encode value._toFullJSON(seenObjects = seenObjects.concat value), seenObjects, disallowObjects if value.hasOwnProperty 'dirty' and typeof value.dirty == 'Function' and !value.dirty()
  # throws error if the object was new/unsaved
  throw 'Tried to save Model with a Pointer to an new or unsaved Object.' if value instanceof $scope.Object and value.isNew()
  # returns Data type as iso encoded object
  return __type:Date, iso: value.toJSON() if _.isDate value
  # returns map of encoded Arrays if value is Array
  return _.map value, ((v)-> $scope._encode v, seenObjects, disallowObjects) if _.isArray value
  # returns source of RegExp if value is RegExp
  return value.source if _.isRegExp value
  # returns $scope.Relation as JSON
  return value.toJSON() if ($scope.Relation and value instanceof $scope.Relation) or ($scope.Op and value instanceof $scope.Op) or ($scope.GeoPoint and value instanceof $scope.GeoPoint)
  # returns a File Object as a Pointer
  if $scope.File and value instanceof $scope.File
    throw 'Tried to save an object containing an unsaved file.' if !value.url()
    return (
      __type: "File"
      name: value.name()
      url: value.url()
    )
  # encodes an arbitrary object
  if _.isObject value
    o = {}
    _.each value, (v, k) -> o[k] = $scope._encode v, seenObjects, disallowObjects
    return o
  # returns raw object as fallback
  value
#### $scope._decode
# > Attempts to JSON decode a given Object
$scope._decode = (key, value)->
  # returns passed value if not an Object
  return value if !_.isObject value
  # handles Array values
  if _.isArray value
    _.each value, (v,k)->
      # recurses each Array value
      value[k] = $scope._decode k, v
    # returns array if sucessfully decoded
    return value
  # returns raw value if is `$scope.Object` 
  return value if (value instanceof $scope.Object) or ($scope.File and value instanceof $scope.File) or ($scope.OP and value instanceof $scope.Op)
  # returns decoded `$scope.OP` objects
  return $scope.OP._decode value if value.__op
  # recreates from Pointer
  if value.__type and value.__type == 'Pointer'
    p = $scope.Object._create value.className
    p._finishFetch {objectId: value.objectId}, false
    return p
  # recreates from Object
  if value.__type and value.__type == 'Object'
    cN = value.className
    delete value.__type
    delete value.className
    o = $scope.Object._create cN
    o._finishFetch value, true
    return o
  # returns `Date` value
  return $scope._parseDate value.iso if value.__type == 'Date'
  # recreates from `$scope.GeoPoint` reference
  if $scope.GeoPoint and value.__type == 'GeoPoint'
    return (new $scope.GeoPoint
      latitude: value.latitude
      longitude: value.longitude
    )
  # recreates from `$scope.Relation` reference
  if $scope.Relation and value.__type == 'Relation'
    (r = new $scope.Relation null, key).targetClassName = value.className
    return r
  # recreates from `$scope.File` reference
  if $scope.File and value.__type == 'File'
    (f = new sarse.File value.name).url = value.url
    return f
  # loops on and decodes and arbitrary object
  _.each value, (v, k) -> value[k] = $scope._decode k, v
  # returns the decoded object
  value
#### $scope.Function
# > Utils to Serialize, Deserialize and Create Functions
$scope.Function = {}
#### $scope.Function.construct(constructor, arguments)
# creates new Function/Object from constructor
$scope.Function.construct = (constructor, args)->
  new ( constructor.bind.apply constructor, [null].concat args )
#### $scope.Function.factory(arguments)
# creates new unnamed Function from passed arguments
$scope.Function.factory = $scope.Function.construct.bind null, Function
#### $scope.Function.fromString(string)
# deserializes and creates unnamed Function from passed string
$scope.Function.fromString = (string)->
  if (m = string.match /^function+\s?\(([a-zA-Z0-9_\s\S\,]?)\)+\s?\{([\s\S]*)\}$/)?
    return $scope.Function.factory _.union m[1], m[2]
  else 
    return if (m = string.match new RegExp "^Native::(#{_.keys($scope.Function.natives).join '|'})+$")? then $scope.Function.natives[m[1]] else null
#### $scope.Function.toString(Function)
# serializes Function to string
$scope.Function.toString = (fun)->
  return fun if typeof fun != 'function'
  if ((s = fun.toString()).match /.*\[native code\].*/)? then "Native::#{$scope.getFunctionName fun}" else s
$scope.Function.natives  = 
  'Date':Date
  'Number':Number
  'String':String
  'Boolean':Boolean
  'Array':Array
  'Object':Object