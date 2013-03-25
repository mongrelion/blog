module CacheHelpers
  def cache_article!(article)
    cache_control :public, :must_revalidate
    last_modified article.date
    etag md5 article.content
  end

  def cache_articles!(articles)
    cache_array! articles
  end

  def cache_readings!(readings)
    cache_array! readings
  end

  def cache_array!(array)
    cache_control :public, :must_revalidate
    etag md5 array.to_s
  end

  protected

  def md5(string)
    Digest::MD5.hexdigest string
  end
end
