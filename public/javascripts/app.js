angular.
  module('app', ['Controllers', 'Services', 'Directives']).
  config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);

    $routeProvider.
      when('/', {
          templateUrl : '/partials/about.html'
        , controller  : 'HomeCtrl'
      }).
      when('/articles', {
          templateUrl : '/partials/articles.html'
        , controller  : 'ArticleListCtrl'
      }).
      when('/articles/:article', {
          templateUrl : '/partials/article.html'
        , controller  : 'ArticleDetailCtrl'
      }).
      when('/readings', {
          templateUrl : '/partials/readings.html'
        , controller  : 'ReadingListCtrl'
      }).
      when('/projects', {
          templateUrl : '/partials/projects.html'
        , controller  : 'ProjectListCtrl'
      }).
      otherwise({
        redirectTo: '/'
      });
  }]);
