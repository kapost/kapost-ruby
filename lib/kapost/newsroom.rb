module Kapost
  module Newsroom
    NEWSROOM_PATH = 'newsroom'.freeze

    # special permissions are needed to hit this endpoint
    def create_newsroom(params)
      post(NEWSROOM_PATH, { :newsroom => params })
    end
  end
end
