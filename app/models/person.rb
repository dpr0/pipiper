# frozen_string_literal: true

class Person < ApplicationRecord
  include Rails.application.routes.url_helpers

  self.table_name = :persons

  default_scope { where(deleted_at: nil) }

  has_one :user
  belongs_to :family_tree, required: false
  has_many :relations
  has_many :facts
  has_many :photos
  has_many :archives
  has_many :infos
  has_many :versions
  has_one_attached :avatar
  has_many_attached :images
  has_many_attached :attachments

  validate :acceptable_avatar
  validate :acceptable_images

  IMAGE_TYPES = %w[image/jpeg image/png].freeze

  def acceptable_avatar
    check_errors(avatar) if avatar.attached?
  end

  def acceptable_images
    images.each { |image| check_errors(image) }
  end

  def full_name
    maiden = maiden_name.present? && maiden_name != last_name ? " (#{maiden_name})" : ''
    "#{last_name}#{maiden} #{first_name} #{middle_name}"
  end

  def fio_name
    "#{maiden_name.present? ? maiden_name : last_name} #{first_name} #{middle_name}"
  end

  def dates
    birth = birthdate.present? && confirmed_birthdate ? birthdate.to_s : ''
    death = deathdate.present? && confirmed_deathdate ? " - #{deathdate}" : ''
    "#{birth}#{death}"
  end

  def parent_ids
    [father_id, mother_id].compact
  end

  def url_for_avatar
    url_for(avatar) if avatar.persisted?
  end

  def images_urls
    images.map do |i|
      url_for(i) if i.persisted?
    end.compact
  end

  def attachments_urls
    attachments.map do |i|
      url_for(i) if i.persisted?
    end.compact
  end

  def update_with_version(event_type, current_user, params)
    Version.prepare(event_type, family_tree.id, current_user, self, params).add
    update(params)
  end

  def thumb_url
    return unless avatar.attached?

    Rails.application.routes.url_helpers.rails_representation_url(avatar.variant(
      combine_options: [
        [:resize, '200x200^'],
        [:gravity, 'center'],
        [:crop, '200x200+0+0'],
        [:strip, true],
        [:quality, '70'],
        [:repage, nil], [:+, nil], # +repage
        [:distort, nil], [:+, 'Perspective']
      ]
    ).processed, only_path: true)
  end

  private

  def check_errors(image)
    errors.add(:image, 'Изображение более 1mb') if image.byte_size > 1.megabyte
    errors.add(:image, 'Изображение должно быть JPEG или PNG') unless IMAGE_TYPES.include?(image.content_type)
  end
end
