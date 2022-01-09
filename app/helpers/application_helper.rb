# frozen_string_literal: true

module ApplicationHelper
  def flash_class(level)
    {
      notice:  'alert alert-info',
      success: 'alert alert-success',
      error:   'alert alert-error',
      alert:   'alert alert-error'
    }[level]
  end

  def provider_color(provider)
    {
      yandex: :danger,
      telegram: :primary
    }[provider]
  end

  def relation_name(rel_type_id)
    rel_type_id == RelationType[:married].id ? RelationType[:married].name : RelationType[:divorced].name
  end

  def sex_color(sex_id)
    "text-#{sex_id == Sex[:male].id ? 'primary' : 'danger'}"
  end
end
