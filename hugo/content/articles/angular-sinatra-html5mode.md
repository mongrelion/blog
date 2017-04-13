[Sinatra], [AngularJS] and HTML5Mode
===

---

##The [Sinatra] Part

<pre class="prettyprint">
  <code>
  get '/*' do
    File.read File.join 'public', 'index.html'
  end
  </code>
</pre>


Put this **at the bottom** of your application file and this will serve your [AngularJS] application at any endpoint. This, of course, will read the *public/index.html* file every time that you head that endpoint. Better if you **memoize** it.

<pre class="prettyprint">
  <code>
  get '/*' do
    render_index
  end

  def render_index
    @index ||= File.read File.join 'public', 'index.html'
  end
  </code>
</pre>

###Important note
Any other route that you register after this snippet won't be triggered as "/*" matches **everything**. Put any route definition before it.

An decent example would look something like this:

<pre class="prettyprint">
  <code>
  class MyApp < Sinatra::Base
    # - Get list of countries - #
    get '/api/v1/countries' do
      # whatever
    end

    # - Get a single country - #
    get '/api/v1/countries/:id' do
      # whatever
    end

    # - Point anything else to the AngularJS app - #
    get '/*' do
      render_index
    end

    def render_index
      @index ||= File.read File.join 'public', 'index.html'
    end
  end
  </code>
</pre>

---

##The [AngularJS] part

Put this in your AngularJS application definition and you should be ready to go:

<pre class="prettyprint">
  <code>
  (function() {
    'use strict';

    var deps = [];
    angular.module('fooApp', deps).
      config(['$locationProvider', function($locationProvider) {
        $locationProvider.html5Mode(true);
      }]);

  }());
  </code>
</pre>

[Sinatra]: http://sinatrarb.com/
[AngularJS]: http://angularjs.org
