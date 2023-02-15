module Services
  class Ping
    def call(addr)
      parse_result(sys_ping(addr))
    end

    private

    def sys_ping(addr)
      `ping6 -c 1 -w 1 #{addr}` if addr.ipv6?
      `ping -c 1 -w 1 #{addr}` if addr.ipv4?
    end

    def parse_result(result_str)
      return [0, false] if result_str.nil? || result_str.empty?

      last_line = result_str.lines.last
      return [0, false] unless last_line.start_with?('rtt')

      rtt = last_line.split(' = ')[1].split('/')[0]
      [rtt.to_f, true]
    end
  end
end