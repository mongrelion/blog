class Model < OpenStruct
  class << self
    def all
      unless @db_file
        raise Exception, 'db_file not set.'
      end

      @all ||= YAML.load_file(db).map { |record| new record }
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
