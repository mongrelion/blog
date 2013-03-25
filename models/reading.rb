class Reading < Base
  # - Attributes - #
  # - title
  # - author
  # - opinion
  # - status
  # - url

  # - Class Methods - #
  class << self
    attr_reader :all
    def all
      @all ||= YAML.load_file(db_path).map { |reading| new reading }
    end

    protected

    def db_path
      File.join root, 'db', 'readings.yml'
    end
  end
end
