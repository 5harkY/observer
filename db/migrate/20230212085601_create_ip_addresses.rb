class CreateIpAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :ip_addresses do |t|
      t.inet :address, null: false
      t.datetime :created_at, null: false
    end
  end
end
