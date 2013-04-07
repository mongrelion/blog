module Model
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def all
      unless @db_file
        raise Exception, 'db_file not set.'
      end
    end

    def set_db_file(name)
      unless name.is_a? Symbol
        raise ArgumentError, "Symbol expected but got #{name.class.name}."
      end
      @db_file = name
    end

    def db_file
      @db_file
    end
  end
end
