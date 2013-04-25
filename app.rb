class App < Sinatra::Base
  helpers ViewHelpers
  include CacheHelpers

  get '/api/v1/projects' do
    @projects = get_projects
    cache_array! @projects
    json @projects
  end

  get '/api/v1/articles' do
    @articles = get_articles
    cache_articles! @articles
    json @articles
  end

  get '/api/v1/articles/:article' do
    if @article = Article.find(params[:article])
      cache_article! @article
      json @article
    else
      raise Sinatra::NotFound
    end
  end

  get '/api/v1/readings' do
    @readings = Reading.all
    cache_array! @readings
    json @readings
  end

  get '/*' do
    cache_control :public, max_age: 604800 # expire in one week
    erb :index, layout: true
  end


  def get_projects
    case params[:type]
    when 'os'
      Project.os
    when 'com'
      Project.com
    else
      Project.all
    end
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
