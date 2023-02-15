class CreateObservations < ActiveRecord::Migration[7.0]
  def change
    create_table :observations do |t|
      t.references :ip_address, null: false
      t.datetime :created_at, null: false
      t.datetime :stopped_at
    end
  end
end
