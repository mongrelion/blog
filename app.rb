class App < Sinatra::Base
  helpers  ViewHelpers

  get '/' do
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
end
