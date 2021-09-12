class AddParametersToCapabilities < ActiveRecord::Migration[6.0]
  def change
    add_column :capabilities, :parameters, :string
  end
end
