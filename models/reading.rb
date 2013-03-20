class Reading < OpenStruct
  # - Attributes - #
  # - title
  # - author
  # - opinion
  # - status
  # - url

  # - Class Methods - #
  class << self
    def all
      YAML.load_file(db_path).map { |reading| new reading }
    end

    protected

    def db_path
      File.join root, 'db', 'readings.yml'
    end
  end
end
