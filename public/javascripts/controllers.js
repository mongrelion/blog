angular.
  module('Controllers', ['Filters']).
  controller('HomeCtrl', [function() {
  }]).
  controller('ArticleListCtrl', ['$scope', 'Article', function($scope, Article) {
    $scope.articles = [];
    Article.query(function(articles) {
      $scope.articles = articles;
    });

    $scope.filterByLang = function(lang) {
      Article.query({ lang : lang }, function(articles) {
        $scope.articles = articles;
      });
    }
  }]).
  controller('ArticleDetailCtrl', ['$scope', '$routeParams', 'Article', function($scope, $routeParams, Article) {
    Article.get({ article : $routeParams.article }, function(article) {
      $scope.article = article;
    })
  }]).
  controller('ReadingListCtrl', ['$scope', 'Reading', function($scope, Reading) {
    $scope.readings = [];
    Reading.query(function(readings) {
      $scope.readings = readings;
    });
  }]).
  controller('ProjectListCtrl', ['$scope', 'Project', function($scope, Project) {
    // OpenSource/Non-Commercial projects
    $scope.osProjects = [];
    Project.query({type : 'os'}, function(projects) {
      $scope.osProjects = projects;
    });

    // Commercial projects
    $scope.comProjects = [];
    Project.query({type : 'com'}, function(projects) {
      $scope.comProjects = projects;
    });
  }]);
