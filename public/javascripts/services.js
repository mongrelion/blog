angular.
  module('Services', ['ngResource']).
  factory('Article', ['$resource', function($resource) {
    var Article = $resource('/articles/:article');
    return Article;
  }]).
  factory('Reading', ['$resource', function($resource) {
    var Reading = $resource('/readings');
    return Reading;
  }]).
  factory('Project', ['$resource', function($resource) {
    var Project = $resource('/projects');
    return Project;
  }]);
