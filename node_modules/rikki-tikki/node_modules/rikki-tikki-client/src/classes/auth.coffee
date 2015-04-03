#### RikkiTikki.Auth
# > Authentication Provider Interface
class $scope.Auth extends $scope.Object
  idAttribute:'session_id'
  constructor:(token)->
    # _.extend @, Backbone.Events
    user  = new $scope.User
    login = null
    token ?= null
    # virtualizes user authentidation test helper method
    @isAuthenticated = =>
      @attributes?[@idAttribute]?
    # virtualizes user login helper method
    @login = (username, password, options)=>
      (login ?= new $scope.Login).login username, password, @createOptions options
    # virtualizes user logout helper method
    @logout = (options)=>
      (login ?= new $scope.Login token:token).logout arguments
    # virtualizes user session restoration helper method
    @restore = (token, options)=>
      (login ?= new $scope.Login token:token).restore token, @createOptions options
    # virtualizes user settings getter method
    @getUser = => user.attributes
    # virtualizes user settings setter method
    @setUser = (attributes, options)=> user.set attributes, @createOptions options
    # virtualizes user user settings update helper method
    @saveUser = (attributes, options)=> user.save attributes, @createOptions options
    # virtualizes user registration helper method
    @registerUser = (attributes, options)=> @saveUser attributes, @createOptions options
    # automatically restores session if token is set
    @restore token if token?