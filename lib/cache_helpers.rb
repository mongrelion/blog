module CacheHelpers
  def cache_article!(article)
    if should_cache?
      cache_control :public, :must_revalidate
      last_modified article.date
      etag md5 article.content
    end
  end

  def cache_articles!(articles)
    cache_array! articles
  end

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
