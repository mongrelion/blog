module Model
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def all
      unless @table_name
        raise Exception, 'table_name not set.'
      end
    end

    def set_table_name(name)
      unless name.is_a? Symbol
        raise ArgumentError, "Symbol expected but got #{name.class.name}."
      end
      @table_name = name
    end

    def table_name
      @table_name
    end
  end
end
