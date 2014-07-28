module Kapost
  module ContentType

    module BodyTypes
      %w(html video photo audio document any_file no_body eloqua_landing_page eloqua_email marketo_landing_page marketo_email google_doc facebook twitter linkedin webinar eloqua_landing_page eloqua_email marketo_landing_page marketo_email video photo audio document any_file google_doc facebook twitter linkedin).each do |type|
        if !const_defined?(type.upcase.to_sym, false)
          const_set(type.upcase, type)
        end
      end
    end

    [:create, :list].each do |action|
      define_method :"#{action}_content_type" do |params|
        send("#{action}_action", 'content_types', params)
      end
    end

    def content_types_params
      @content_types_params || {}.tap do |p|
        p[:create] = [
          :field_name, :display_name, :body_type
        ]

        p[:list] = []
      end
    end
  end
end
