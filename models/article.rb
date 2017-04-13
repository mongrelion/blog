class Article < Model
  set_db_file :articles

  # - Attributes - #
  # * title
  # * date
  # * file
  # * intro
  # * tags
  # * spanish_version [might not be present always]
  # * english_version [might not be present always]

  # - Instance Methods - #
  def initialize(args)
    super args
    self.content
    self
  end

  def content
    path = File.join(root, "hugo", "content", "articles", "#{file}.md")
    if file and File.exists?(path)
      @content ||= RDiscount.new(File.read path).to_html
    end
  end

  def to_h
    super.merge! content: content
  end

  # - Class Methods - #
  class << self
    def find(slug)
      all.select { |article| article.file.include? slug }.first
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

  end
end
