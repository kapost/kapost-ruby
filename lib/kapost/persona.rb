module Kapost
  module Persona

    [:create, :list].each do |action|
      define_method :"#{action}_persona" do |params|
        send("#{action}_action", 'personas', params)
      end
    end

    def personas_params
      @personas_params || {}.tap do |p|
        p[:create] = [
            :name
        ]

        p[:list] = []
      end
    end
  end
end