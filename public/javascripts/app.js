angular.
  module('app', ['Controllers', 'Services']).
  config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider.
      when('/articles', {
          templateUrl : '/partials/articles.html'
        , controller  : 'ArticleListCtrl'
      }).
      when('/articles/:article', {
          templateUrl : '/partials/article.html'
        , controller  : 'ArticleDetailCtrl'
      }).
      when('/projects', {
          templateUrl : '/partials/projects.html'
        , controller  : 'ProjectListCtrl'
      }).
      when('/readings', {
          templateUrl : '/partials/readings.html'
        , controller  : 'ReadingListCtrl'
      }).
      when('/movies', {
          templateUrl : '/partials/movies.html'
        , controller  : 'MovieListCtrl'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);
