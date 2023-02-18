class CreateObservationResults < ActiveRecord::Migration[7.0]
  def change
    hypertable_options = {
      time_column: 'created_at',
      chunk_time_interval: '1 min',
      compress_segmentby: 'ip_address_id',
      compression_interval: '7 days'
    }

    create_table(:observation_results, id: false, hypertable: hypertable_options) do |t|

      t.references :ip_address, null: false
      t.float :rtt
      t.boolean :success, null: false
      t.datetime :created_at, null: false
    end
  end
end
