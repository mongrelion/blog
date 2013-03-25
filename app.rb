class App < Sinatra::Base
  helpers ViewHelpers
  include CacheHelpers

  get '/' do
    cache_control :public, max_age: 604800 # expire in one week
    erb :index, layout: true
  end

  get '/articles' do
    @articles = get_articles
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

  def get_articles
    case params[:lang]
    when 'english'
      Article.english
    when 'spanish'
      Article.spanish
    else
      Article.all
    end
  end
end
