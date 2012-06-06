class Mongreliog < Sinatra::Base
  register Sinatra::Synchrony
  helpers  ViewHelpers

  get '/' do
    cache_control :public, :max_age => 36000
    erb :about
  end

  get '/articles' do
    @articles = Article.all
    erb :articles
  end

  get '/articles/en' do
    @articles = Article.english
    erb :articles
  end

  get '/articles/es' do
    @articles = Article.spanish
    erb :articles
  end

  get '/articles/:article' do
    if @article = Article.find(params[:article])
      erb :article
    else
      raise Sinatra::NotFound
    end
  end

  %w[projects books movies].each do |route|
    get("/#{route}") { redirect to '/' }
  end

  def set_cache_control(max_age)
    max_age ||= 600
    request['Cache-Control'] = "public, max-age=#{max_age}"
  end
end
