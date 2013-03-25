class Base < OpenStruct
  # - Instance Methods - #
  def to_json(options = {})
    @json ||= to_h.to_json options
  end
end
