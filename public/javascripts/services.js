angular.
  module('Services', ['ngResource']).
  factory('Article', ['$resource', function($resource) {
    var Article = $resource('/articles/:article');
    return Article;
  }]);
