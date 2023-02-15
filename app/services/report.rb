module Services
  class Report
    def call(address:, start_time:, end_time:)
      addr = IpAddress.find_by(address:)
      observations = addr.observation_results.where('created_at >= ?', start_time)
                         .where('created_at <= ?', end_time).order(:rtt)
      success_observations = observations.where(success: true)
      success_rtts = success_observations.pluck(:rtt)
      avg_rtt = avg(success_rtts)

      {
        avg_rtt:,
        min_rtt: success_rtts.first || 0,
        max_rtt: success_rtts.last || 0,
        median_rtt: median(success_rtts),
        std_deviation: std_deviation(success_rtts, avg_rtt),
        lost_percentage: lost_percentage(success_observations.count, observations.count),
        observations: observations.count,
        success_observations: success_observations.count
      }
    end

    private

    def avg(arr)
      return 0 if arr.count.zero?

      arr.sum / arr.count
    end

    def median(arr)
      len = arr.length
      return 0 if len.zero?
      return arr[0] if len == 1

      (arr[(len - 1) / 2] + arr[len / 2]) / 2.0
    end

    def variance(arr, mean)
      return 0 if arr.size.zero?

      sum = 0.0
      arr.each {|v| sum += (v - mean)**2 }
      sum / arr.size
    end

    def std_deviation(arr, mean)
      return 0 if arr.size.zero?

      Math.sqrt(variance(arr, mean))
    end

    def lost_percentage(success, total)
      return 0 if total.zero?

      failed = total - success
      100.0 * failed / total
    end

  end
end