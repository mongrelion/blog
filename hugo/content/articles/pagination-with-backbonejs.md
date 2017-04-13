You have pagination in your [Rails] site using [WillPaginate] or [Kaminari].
You are now using [Backbone] and you want that pagination to dance AJAX.
In this guide I will show you the steps so you can rock the party!

My approach might not be the best but it isn't the worst either. It works, though.
To integrate [Backbone] with [Rails] I use a gem called [backbone-on-rails], but
basically this works for any way that you use to integrate [Backbone] with your
project.

So, without too much chit chat, here we go:

First, make sure you've got the your pagination library in your Gemfile:

<pre>
  <code class="ruby">
    # Gemfile
    source :rubygems
    # ...
    gem 'will_paginate'

    group :assets do
      gem 'backbone-on-rails'
    end
  </code>
</pre>

Now let's say that we want to manage a list of articles. Model and controller
look more or less like this:

<pre>
  <code class="ruby">
    # app/models/article.rb
    class Article < ActiveRecord::Base
    end
  </code>
</pre>

<pre>
  <code class="ruby">
    # app/controllers/articles_controller.rb
    class ArticlesController < ApplicationController
      def index
        respond_with @articles = Article.page(params[:page])
      end
      # And the other controller actions (new, show, edit, etc.)
    end
  </code>
</pre>

Let's prepare our Backbone's model and collection:
<pre>
  <code class="coffeescript">
    # app/assets/javascripts/models/article.coffee.js
    class App.Models.Article extends Backbone.Model
  </code>
</pre>

Now, a good approach, as suggested by Backbone's author, is to bootstrap our
collections, so that when we render the Rails views, the collection is already
there waiting to be processed by our client side code:

<pre>
  <code class="xml">
  <table class="">
  </table>
    &lt;script type="text/javascript"&gt;
      window.articles = <%=j @articles.to_json %>;
    &lt;/script&gt;
  </code>
</pre>

[Backbone]: http://documentcloud.github.com/backbone
[Rails]: http://rubyonrails.org
[WillPaginate]: http://rubygems.org/gems/will_paginate
[Kaminari]: http://rubygems.org/gems/kaminari
[backbone-on-rails]: https://github.com/meleyal/backbone-on-rails
