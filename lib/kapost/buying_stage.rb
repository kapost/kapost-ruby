module Kapost
  module BuyingStage

    [:create, :list, :update, :delete].each do |action|
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
        p[:update] = p[:create] + [:id]
        p[:delete] = [:id]
      end
    end
  end
end