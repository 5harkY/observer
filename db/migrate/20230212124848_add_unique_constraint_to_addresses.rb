class AddUniqueConstraintToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_index :ip_addresses, :address, unique: true
  end
end
