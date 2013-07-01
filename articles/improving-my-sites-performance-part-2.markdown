A couple of weeks ago I decided to internally improve my website.
Here I explain exactly what is it that I did to do so.
Some of these changes include ruby memoize/memoization and Sinatra Caching.

As I previously mentioned, my blog's architechture is inspired in [@cyx]'s personal
website. However, I was not totally comfortable with the fact that everytime
that a page was requested (a blog post in this case), the application had to
go to disk, bring the blgo post, parse the markdown and then render the view.  
It was something more or less like this:
<pre class="prettyprint">
  <code>
  # app.rb
  class App < Sinatra::Application
    get '/articles/:article' do
      if @article = Article.find(params[:article])
        erb :article
      else
        raise Sinatra::NotFound
      end
    end
  end

  # models/article.rb
  class Article < OpenStruct
    # - Instance Methods - #
    def content
      RDiscount.new(File.read File.join root, 'articles', file).to_html if file
    end

    # - Class Methods - #
    class << self
      def all
        YAML.load_file(db_path).map { |article| new article }
      end

      def find(slug)
        all.select { |article| article.file.include? slug }.first
      end

      protected

      def db_path
        File.join root, 'db', 'articles.yml'
      end
    end
  end
  </code>
</pre>
And in the view I had something very simple, more or less like this:
<pre class="prettyprint">
  <code>
  <%= @article.content %>
  </code>
</pre>
Everything was pretty simple. In the end, it's a blog, right? There's no reason
to be fancy and make very complicated things. But, well, at the same time, this
is my personal website, and it deserves as much love as any other application
that I code, paid or unpaid. So, I thought that the first thing I could do was
to cache the array of articles and also the returned value by _Article#content_.  
It was also a really good opportunity to abstract the logic that I had repeated
in between the models Article and Reading, so I ended up with something like this:  
(code has been reduced):
<pre class="prettyprint">
  <code>
  # lib/model.rb
  class Model < OpenStruct
    # - Class Methods - #
    class << self
      def all
        @all ||= YAML.load_file(db) { |record| new record }
      end
    end
  end

  # models/article.rb
  class Artcle < Model
    # - Instance Methods - #
    def initialize(args)
      super args
      self.content
      self
    end

    def content
      @content ||= RDiscount.new(File.read path).to_html
    end
  end
  </code>
</pre>
Now, every time that the _Article#all_ method is called, all the articles are
going to be memoized and each time that a new instance of an article is created
the markdown is going to be parsed and memoized.  
But none of this would happen until the first person visited the list of articles.
Every time that a new version of the application is deployed to production, though,
I could call the list in the config.ru file to make a pre-initialization caching.  
Cada vez que despliegue una nuvea versión de la aplicación a producción
Let's see:  
<pre class="prettyprint">
  <code>
  # config.ru
  require './models/article'
  require './models/reading'
  require './app'

  # Preload articles and readings.
  Article.all
  Reading.all
  run Application
  </code>
</pre>
That's it. Now everytime that someone visits the list of articles and/or readings,
the arrays are already loaded in memory with articles and readings ready to be served,
even with the markdown parsed!

The next step was to migrate my site to [AngularJS]. For this I had to serve
my resources (articles and readings) via JSON. Easy. I'm already using OpenStruct,
so the last step was to serve the hash of my instances formatted to JSON:  
<pre class="prettyprint">
  <code>
  # lib/model.rb
  class Model < OpenStruct
    # - Instance Methods - #
    def to_json(options = {})
      @json ||= to_h.to_json options
    end
  end
  </code>
</pre>
Because the content doesn't change that much, I can cache my JSON response, so:  
<pre class="prettyprint">
  <code>
  # lib/cache_helpers.rb
  module CacheHelpers
    def cache_array!(array)
      if should_cache?
        cache_control :public, :must_revalidate
        etag md5 array.to_s
      end
    end
    protected

    def md5(string)
      Digest::MD5.hexdigest string
    end

    def should_cache?
      settings.production?
    end
  end

  # app.rb
  class Application < Sinatra::Application
    include CacheHelpers
    get '/api/v1/articles' do
      @articles = get_articles
      cache_articles! @articles
      json @articles
    end
  end
  </code>
</pre>
The CacheHelpers#md5 method generates a hash from a string (the JSON array of my
articles and whatever), then I send that value through the [ETag] header.
And that's it. Whenever I add a new article, I commit the change, push it to [GitHub]
and then I deploy the changes into produciton using [Mina] and then I order [Puma]
to restart and that's it.

[AngularJS]: http://angularjs.org
[ETag]: http://en.wikipedia.org/wiki/HTTP_ETag
[Puma]: http://puma.io
[GitHub]: https://github.com
[Mina]: http://nadarei.co/mina/
