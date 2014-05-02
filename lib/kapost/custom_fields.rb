module Kapost
  module CustomFields

    [:create, :list, :show, :update, :delete].each do |action|
      define_method :"#{action}_custom_fields" do |params|
        send("#{action}_action", 'custom_fields', params)
      end
    end

    def custom_fields_params
      @content_params || {}.tap do |p|
        p[:create] = [
          :field_type, :display_label, :name, :location, :default_value,
          :rss_field_type, :select_values, :editor_or_admin_only,
          :display_as_column_selector, :display_as_filter, :required_field,
          :html, :multiline
        ]

        p[:list] = [
          :page, :per_page
        ]

        p[:update] = (p[:create] - [:field_type]) + [:id]
        p[:show] = [:id]
        p[:delete] = [:id]
      end
    end
  end
end
