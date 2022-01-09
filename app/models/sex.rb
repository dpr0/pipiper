# frozen_string_literal: true

class Sex < ApplicationRecord
  self.table_name = 'sex'
  include Dictionary
end
