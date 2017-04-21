+++
title = "AngularJS, Sinatra and HTML5Mode"
date = "2013-09-13T00:00:00+00:00"
description = "How to enable Sinatra for serving Single Page Applications with AngularJS with HTML5 mode enabled"
tags = ["javascript", "js", "angularjs", "angular", "ng", "ruby", "sinatra", "html5", "html5mode"]
+++

[Sinatra], [AngularJS] and HTML5Mode
===

---

## The [Sinatra] Part
```ruby
get "/*" do
  File.read(File.join("public", "index.html"))
end
```

Put this **at the bottom** of your application file and this will serve your
[AngularJS] application at any endpoint. This, of course, will read the
`public/index.html` file every time that you head that endpoint. Better if you
**memoize** it.

```ruby
get "/*" do
  render_index
end

def render_index
  @index ||= File.read(File.join("public", "index.html"))
end
```

### Important note
Any other route that you register after this snippet won't be triggered as `"/*"` matches **everything**. Put any route definition before it.

A decent example would look something like this:

```ruby
class MyApp < Sinatra::Base
  # - Get list of countries - #
  get "/api/v1/countries" do
    # whatever
  end

  # - Get a single country - #
  get "/api/v1/countries/:id" do
    # whatever
  end

  # - Point anything else to the AngularJS app - #
  get "/*" do
    render_index
  end

  def render_index
    @index ||= File.read(File.join("public", "index.html")
  end
end
```
---

## The [AngularJS] part

Put this in your AngularJS application definition and you should be ready to go:

```javascript
(function() {
  "use strict";

  var deps = [];
  angular.module("fooApp", deps).
    config(["$locationProvider", function($locationProvider) {
      $locationProvider.html5Mode(true);
    }]);

}());
```

[Sinatra]: http://sinatrarb.com/
[AngularJS]: http://angularjs.org
