module ViewHelpers
  def article_path(article_slug)
    "/articles/#{article_slug}"
  end

  def lastfm_api_key
    ENV['LASTFM_API_KEY'] || "14b0cceac63c07bdd8c242423709670d"
  end

  def published_at(lang)
    if lang.eql? 'spanish'
      'Publicado en'
    elsif lang.eql? 'english'
      'Published at'
    end
  end

  def read_more(lang)
    if lang.eql? 'spanish'
      'Seguir leyendo'
    elsif lang.eql? 'english'
      'Read more'
    end
  end
end
