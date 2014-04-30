module Kapost
  class Result
    attr_accessor :code, :data, :success

    def initialize(code, data)
      self.code = code
      self.data = data
      self.success = (code <= 399)
    end
  end
end
