module Kapost
  class Result
    attr_accessor :code, :data, :success

    def initialize(code, data)
      self.code = code
      self.data = data
      self.success = (code < 300)
    end

    def data=(value)
      if value.is_a? String
        value = { :error_description => value }
      end

      @data = value
    end
  end
end
