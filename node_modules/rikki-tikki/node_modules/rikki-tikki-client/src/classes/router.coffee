#### $scope.Query
#> Provides singleton access to virtualized Backbone.Router instance
class $scope.Router extends $scope.Singleton
  #### constructor()
  # > Class Constructor Method
  constructor:->
    # virtualizes an instance of Bbackbone.Router
    _router = new Backbone.Router
    #### $scope.Router.routes( object )
    # > sets routes on Router instance
    $scope.Router::routes = (r)=>
      # invokes routes with args
      _router.routes r
    #### $scope.Router.routes( route, name, callback )
    # > adds a route to the Router instance
    $scope.Router::route = (r,n,cB)=>
      # invokes route with args
      _router.route r,n,cB
    #### $scope.Router.navigte( path, opts )
    # > navigates to the given path
    $scope.Router::navigate = (p,opts)=>
      # invokes navigate with args
      _router.navigate p,opts
    #### $scope.Router.execute( callback, args )
    # > executes the matching callback
    $scope.Router::execute = (cB, args)=>
      # invokes execute with args
      _router.execute cB, args
#### $scope.Router.getInstance()
# > returns instance of Router
$scope.Router.getInstance = =>
  @__instance ?= new $scope.Router()