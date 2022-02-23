class AddProtocolIdToDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :devices, :protocol_id, :integer
  end
end
