+++
title = "Mejorando el rendimiento de mi sitio (¿?): Parte II"
date = "2013-07-01T00:00:00+00:00"
description = "Segunda y última parte de la historia de cómo mejoré el rendimiento de mi sitio escrito en Ruby"
tags = ["ruby"]
+++

Hace un par de semanas decidí hacerle unas mejoras internas a mi sitio
para mejorar su rendimiento. Aquí explico qué fue exactamente lo que hice.

Como mencioné anteriormente, la arquitectura de mi blog está insirapada en el
sitio personal de [@cyx]. Sin embargo, no estaba del todo a gusto con el hecho
que cada vez que se solicitaba una página (un blog post en este caso), la
aplicación tenía que ir al disco duro, traer el blog post, parsear™ el markdown
y luego renderizar™ la vista.  
Era algo más o menos así:  
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
Y en la vista tenía algo muy sencillo, del siguiente orden:
<pre class="prettyprint">
  <code>
  <%= @article.content %>
  </code>
</pre>
Todo muy sencillo. Al fin y al cabo, es un blog, ¿cierto? No hay por qué recatarse
con cosas muy complicadas. Pero bueno, al fin y al cabo es el sitio de uno y vale
la pena meterle cariño a la cosa, así que pensé que lo primero que podía hacer
era cachear™ el array de artículos y de paso el valor retornado por _Article#content_.  
También era una buena oportunidad para abstraer la lógica que tenía repetida entre
los modelos Article y Reading, así que terminé con algo así:  
(el código ha sido reducido con el fin de simplificar el ejemplo):
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
Ahora, cada vez que se llame Article#all, todos los artículos van a ser memoizados™
y cada vez que se cree una nueva instancia de un artículo, el markdown va a ser
parseado™ y memoizado™.  
Pero nada de esto sucedería hasta que la primera persona visite la lista de artículos.
Aunque cada vez que despliegue una nuvea versión de la aplicación a producción
en el config.ru podría llamar a la lista para hacer un pre-initialization caching.  
Veamos:  
<pre class="prettyprint">
  <code>
  # config.ru
  require './models/article'
  require './models/reading'
  require './app'

  # Precargar artículos y lecturas
  Article.all
  Reading.all
  run Application
  </code>
</pre>
Eso es todo. Ahora cada que alguien visite la lista de artículos y lecturas el
los arreglos ya están con los artículos y lecturas cargados en memoria listos
para ser servidos, con el markdown parseado™ y tal.

Lo siguiente que hice fue migrar mi sitio a [AngularJS]. Esto me obligó a servir
mis recursos (articles y lecturas) via JSON. Fácil. Yo estoy usando OpenStruct,
así que lo único que tenía que hacer era servir el hash de mis instancias formateados
a JSON:  
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
Como el contenido no cambia de a mucho, puedo cachear™ mi JSON response, así que:  
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
El método CacheHelpers#md5 genera un hash de una cadena de texto (el arreglo JSON
de mis artículos y cualquier otro), luego envío ese valor a través de la cabecera [ETag].
Y ajá, eso es todo. Cuando agrego un nuevo artículo, hago el commit con git,
subo los cambios a [GitHub] y luego despliego los cambios a producción usando [Mina],
y luego ordeno un restart a [Puma] y ya.

[AngularJS]: http://angularjs.org
[ETag]: http://en.wikipedia.org/wiki/HTTP_ETag
[Puma]: http://puma.io
[GitHub]: https://github.com
[Mina]: http://nadarei.co/mina/
