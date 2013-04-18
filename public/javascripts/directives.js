angular.
  module('Directives', []).
  directive('fancyArticle', function($timeout) {
    var definition = {
        templateUrl : '/directives/fancy-article.html'
      , replace     : true
      , transclude  : false
      , restrict    : 'E'
      , scope       : {
          article : '=ngModel'
        }
      , link        : function postLink(scope, iElement, iAttrs, controller) {
          $timeout(function() {
            prettyPrint();
          }, 1000);
        }
    };
    return definition;
  }).
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
