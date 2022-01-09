# frozen_string_literal: true

class Photo < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :person
  has_one_attached :attachment

  default_scope { where(deleted_at: nil) }

  def attachment_url
    url_for(attachment) if attachment.persisted?
  end
end
