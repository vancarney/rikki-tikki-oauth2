#### $scope.UserCollection
# Collection to retrieve and manage Parse User Objects
class $scope.Users extends $scope.Collection
  url:->
    "#{$scope.API_URI}/users"