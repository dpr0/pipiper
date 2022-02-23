# frozen_string_literal: true

class Protocol < ApplicationRecord
  include Dictionary
  has_many :devices
end
