class Project < Model
  set_db_file :projects

  # - Attributes - #
  # * name
  # * url
  # * screenshot
  # * team
  # * team_url
  # * type [os for OpenSource and com for Commercial]
  # * description

  # - Class Methods - #
  class << self
    def by_type(type)
      all.select { |project| project.type.eql? type }
    end

    def os
      by_type 'os'
    end

    def com
      by_type 'com'
    end
  end
end
