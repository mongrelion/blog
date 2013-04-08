class Model < OpenStruct
  # - Instance Methods - #
  def to_json(options = {})
    @json ||= to_h.to_json options
  end

  # - Class Methods - #
  class << self
    def all
      unless @db_file
        raise Exception, 'db_file not set.'
      end

      if records = YAML.load_file(db)
        @all ||= records.map { |record| new record }
      else
        @all ||= []
      end
    end

    def set_db_file name
      unless name.is_a? Symbol
        raise ArgumentError, "Symbol expected but got #{name.class.name}."
      end
      @db_file = name
    end

    def db_file
      @db_file
    end

    private

    def base_dir
      File.join root, 'db'
    end

    def db
      File.join base_dir, "#{db_file}.yml"
    end
  end
end
