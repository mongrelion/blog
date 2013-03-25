angular.
  module('Filters', []).
  filter('articlePath', function() {
    return function(file) {
      return "/#/articles/" + file;
    };
  }).
  filter('readMore', function() {
    return function(lang) {
      if ('spanish' == lang) {
        return 'Seguir leyendo';
      } else {
        return 'Read more';
      }
    };
  }).
  filter('publishedAt', function() {
    return function(lang) {
      if ('spanish' == lang) {
        return 'Publicado en';
      } else {
        return 'Published at';
      }
    }
  });
