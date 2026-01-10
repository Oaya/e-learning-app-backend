require "aws-sdk-s3"

module S3
  extend ActiveSupport::Concern

  private

  def s3_bucket = Rails.application.credentials.dig(:aws, :s3_bucket)

  def s3_region = Rails.application.credentials.dig(:aws, :region)

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region: Rails.application.credentials.dig(:aws, :region),
      access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
    )
  end

  def presigner
    @presigner ||= Aws::S3::Presigner.new(client: s3_client)
  end

  def presigned_put_url(key:, content_type:)
    presigner.presigned_url(
      :put_object,
      bucket: s3_bucket,
      key: key,
      content_type: content_type,
      acl: "private",
      expires_in: 300
    )
  end

  def presigned_get_url(key:)
    presigner.presigned_url(
      :get_object,
      bucket: s3_bucket,
      key: key,
      expires_in: 300
    )
  end

  def presigned_delete_url(key:)
    presigner.presigned_url(
      :delete_object,
      bucket: s3_bucket,
      key: key,
      expires_in: 300
    )
  end
end
