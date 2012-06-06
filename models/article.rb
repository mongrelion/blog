class Article < OpenStruct
  # - Attributes - #
  # - title
  # - date
  # - file
  # - intro
  # - tags
  # - spanish_version [might not be present always]
  # - english_version [might not be present always]

  # - Instance Methods - #
  def content
    if file
      RDiscount.new(File.read File.join(root, 'articles', file)).to_html
    end
  end

  def slug
    file.match(/^(.+).markdown$/)[1] if file
  end

  def spanish?
    lang.eql? 'spanish'
  end

  # - Class Methods - #
  class << self

    def all
      YAML.load_file(db_path).map { |article| new article }
    end

    def spanish
      by_lang 'spanish'
    end

    def english
      by_lang 'english'
    end

    def by_lang(lang)
      all.select { |article| article.lang.eql? lang }
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
