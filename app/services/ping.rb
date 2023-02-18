# frozen_string_literal: true

require 'open3'

module Services
  class Ping
    def call(addr, timeout_sec = 1)
      parse_result(sys_ping(addr, timeout_sec))
    end

    private

    def sys_ping(addr, timeout_sec)
      addr = begin
        IPAddr.new(addr)
      rescue IPAddr::InvalidAddressError, IPAddr::AddressFamilyError
        nil
      end
      return unless addr

      begin
        Timeout.timeout(timeout_sec + 1) do
          ping_cmd = addr.ipv6? ? 'ping6' : 'ping'
          out, _err, _st = Open3.capture3(ping_cmd, '-c', '1', '-W', '1', addr.to_s)
          out
        end
      rescue Timeout::Error
        nil
      end
    end

    def parse_result(result_str)
      return [0, false] if result_str.nil? || result_str.empty?

      last_line = result_str.lines.last
      return [0, false] unless last_line.include?('min/avg/max')

      rtt = last_line.split(' = ')[1].split('/')[0]
      [rtt.to_f, true]
    end
  end
end
