module Kapost
  module BuyingStage

    [:create, :list].each do |action|
      define_method :"#{action}_buying_stage" do |params|
        send("#{action}_action", 'buying_stages', params)
      end
    end

    def buying_stages_params
      @buying_stages_params || {}.tap do |p|
        p[:create] = [
            :name
        ]

        p[:list] = []
      end
    end
  end
end