class Article < Base
  # - Attributes - #
  # - title
  # - date
  # - file
  # - intro
  # - tags
  # - spanish_version [might not be present always]
  # - english_version [might not be present always]

  # - Instance Methods - #
  def initialize(args)
    super args
    self.content
    self
  end

  def content
    if file
      @content ||= RDiscount.new(File.read File.join(root, 'articles', "#{file}.markdown")).to_html
    end
  end

  def to_h
    super.merge! content: content
  end

  # - Class Methods - #
  class << self
    attr_accessor :all
    def all
      @all ||= YAML.load_file(db_path).map { |article| new article }
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
