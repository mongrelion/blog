class App < Sinatra::Base
  helpers ViewHelpers
  include CacheHelpers

  get '/' do
    cache_control :public, max_age: 604800 # expire in one week
    erb :about
  end

  get '/articles' do
    @articles = Article.all
    cache_articles! @articles
    json @articles
  end

  get '/articles/en' do
    @articles = Article.english
    cache_articles! @articles
    json @articles
  end

  get '/articles/es' do
    @articles = Article.spanish
    cache_articles! @articles
    json @articles
  end

  get '/articles/:article' do
    if @article = Article.find(params[:article])
      cache_article! @article
      json @article
    else
      raise Sinatra::NotFound
    end
  end

  get '/readings' do
    @readings = Reading.all
    cache_readings! @readings
    json @readings
  end

  %w[projects movies].each do |route|
    get("/#{route}") { redirect to '/' }
  end
end
