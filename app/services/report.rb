# frozen_string_literal: true

module Services
  class Report
    def call(address:, start_time:, end_time:)
      addr = IpAddress.find_by(address:)
      return {} unless addr

      base_query = addr.observation_results.where(created_at: (start_time..end_time))

      result = base_query.where(success: true).select("
        AVG(rtt) AS avg_rtt,
        MIN(rtt) AS min_rtt,
        MAX(rtt) AS max_rtt,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rtt) AS median_rtt,
        STDDEV(rtt) AS std_deviation
      ").map { |r| r.attributes.symbolize_keys }.first

      lost_percentage = base_query.select('AVG( (NOT success)::int * 100) AS val').first['val'].to_f

      result.merge(lost_percentage:)
    end
  end
end
