#### $scope.Login
# > Implements Login functionality
class $scope.Login extends $scope.Object
  idAttribute:'token'
  defaults:
    email:String
    password:String
  constructor:->
    Login.__super__.constructor.apply @, arguments
    # overrides default pluralized upper-case classname
    @className = "login"
  validate:(o)->
    email = o.email || @attributes.email || null
    password = o.token || @attributes.password || null
    token = o.token || @attributes.token || null
    # tests for basic authentication
    if email?
      # invalidates if password IS NOT set
      return "password required" unless password?
      # invalidates if token IS set
      return "password required" if  token?
    # tests for bearer token authentication
    if token?
      # invalidates if email IS set
      return "token based authentication does not use email address" if email?
      # invalidates if password IS set
      return "token based authentication does not use password" if password?
  login:(email, password, options)->
    @save {email:email, password:password}, options
  logout:(options)->
    @destroy()
  restore:(token, options)->
    @fetch token:token, options
  isAuthenticated:->
    @attributes[@idAttribute]?