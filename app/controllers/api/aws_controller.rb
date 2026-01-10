
class Api::AwsController < ApplicationController
  include S3

  ALLOWED_CONTENT_TYPES = [
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp"
  ].freeze

  MAX_BYTES = 5.megabytes

  def presigned_url
    filename  = params.require(:filename)
    content_type = params.require(:content_type)
    byte_size = params.require(:byte_size).to_i

    unless ALLOWED_CONTENT_TYPES.include?(content_type)
      return render_error("unsupported_type", status: :unprocessable_entity)
    end

    if byte_size <= 0 || byte_size > MAX_BYTES
      return render_error("file_too_large", status: :unprocessable_entity)
    end

    key = build_course_thumbnail_key(filename)

    render json: {
      key: key,
      put_url: presigned_put_url(
        key: key,
        content_type: content_type
      )
    }
  end

  def delete_object
    key = params.require(:key)

    if Current.tenant && !key.start_with?("tenants/#{Current.tenant.id}/")
      return render_error("forbidden", status: :forbidden)
    end

    delete_url = presigned_delete_url(key: key)
    render json: { delete_url: delete_url }
  end

  private

  def build_course_thumbnail_key(filename)
    safe = filename.gsub(/[^\w.\-]/, "_")

    tenant_prefix =
      defined?(Current) && Current.respond_to?(:tenant) && Current.tenant ?
        "tenants/#{Current.tenant.id}/" :
        ""

    "#{tenant_prefix}course-thumbnails/#{SecureRandom.uuid}-#{safe}"
  end
end
