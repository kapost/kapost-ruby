module Kapost
  module Content

    [:create, :list, :show, :update, :delete].each do |action|
      define_method :"#{action}_content" do |params|
        send("#{action}_action", 'content', params)
      end
    end

    def content_params
      @content_params || {}.tap do |p|
        p[:create] = [
          :idea_title, :idea, :content_title, :content, :assignee_id,
          :privacy, :invitee_ids, :is_draft, :campaign_ids,
          :submission_deadline, :publish_deadline, :payment_type,
          :payment_fixed_rate, :tags, :external_file_url,
          :persona_ids, :stage_ids, :content_type_id, :custom_fields
        ]

        p[:list] = [
          :detail, :page, :per_page, :user_id, :campaign_id, :category,
          :include_empty_categories, :date_type, :start, :end,
          :listener_id, :content_type_id, :search, :content_number, :state
        ]

        p[:update] = p[:create] + [:id, :reject_reason, :operation]
        p[:show] = [:id, :detail]
        p[:delete] = [:id]
      end
    end
  end
end
