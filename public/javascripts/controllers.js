angular.
  module('Controllers', ['Filters']).
  controller('ArticleListCtrl', ['$scope', 'Article', function($scope, Article) {
    $scope.articles = [];
    Article.query(function(articles) {
      $scope.articles = articles;
    });
  }]).
  controller('ArticleDetailCtrl', ['$scope', '$routeParams', 'Article', function($scope, $routeParams, Article) {
    Article.get({ article : $routeParams.article }, function(article) {
      $scope.article = article;
    })
  }]);
