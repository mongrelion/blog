angular.
  module('Services', ['ngResource']).
  factory('Article', ['$resource', function($resource) {
    var Article = $resource('/api/v1/articles/:article');
    return Article;
  }]).
  factory('Reading', ['$resource', function($resource) {
    var Reading = $resource('/api/v1/readings');
    return Reading;
  }]).
  factory('Project', ['$resource', function($resource) {
    var Project = $resource('/api/v1/projects');
    return Project;
  }]);
