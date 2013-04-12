angular.
  module('Directives', []).
  directive('projects', function() {
    var definition = {
        templateUrl : '/directives/projects.html'
      , replace     : true
      , transclude  : false
      , restrict    : 'E'
      , scope       : {
          projects : '=collection'
        }
    };
    return definition;
  });
