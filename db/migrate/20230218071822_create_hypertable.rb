class CreateHypertable < ActiveRecord::Migration[7.0]
  def change
    execute "SELECT create_hypertable('observation_results', 'created_at', migrate_data => true);"
    execute "CREATE INDEX index_observation_results_on_rtt_created_at ON observation_results (rtt, created_at DESC);"
  end
end
