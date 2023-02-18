class CreateObservationResults < ActiveRecord::Migration[7.0]
  def change
    create_table :observation_results, id: false do |t|
      t.references :ip_address, null: false
      t.float :rtt
      t.boolean :success, null: false
      t.datetime :created_at, null: false
    end
  end
end
