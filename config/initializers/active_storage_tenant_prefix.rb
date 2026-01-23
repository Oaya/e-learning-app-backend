Rails.application.config.to_prepare do
  ActiveStorage::Attachment.class_eval do
    before_create :set_key_prefix

    private

    def set_key_prefix
      return unless record && blob && defined?(Current) && Current.tenant

      type_prefix =
        case name.to_s
        when "avatar" then "avatars"
        when "thumbnail" then "thumbnails"
        when "video" then "videos"
        else "uploads"
        end

      blob.key = "tenants/#{Current.tenant.id}/#{type_prefix}/#{blob.key}"
    end
  end
end
