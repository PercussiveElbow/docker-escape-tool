require "math"
require "./ping/icmp"
require "./ping/client"
require "./ping/result"

# TODO: Write documentation for `Ping`
module NetSample::Ping
  VERSION = "0.1.0"

  class Error < Exception; end

  def self.command(host : String, *, count : UInt16 = 5u16, data = "ping!")
    raise Error.new("ping count must be greater than 0.") unless count > 0
    data_length = [56, data.size].max
    puts "PING #{host}: #{data_length} data bytes"

    client = Ping::Client.new(host)
    id = Process.pid.to_u16
    sequence = 0u16
    rtt_list = [] of Float64
    while sequence < count
      res = client.ping(id, sequence, data)
      puts res.message
      rtt_list << res.rtt if res.is_a?(EchoReplyReceived) && res.valid?
      sleep(1)
      sequence += 1
    end
    received = rtt_list.size
    puts "\n--- #{host} ping statistics ---"
    puts "#{count} packets transmitted, #{received} packets received, #{"%.1d" % (100.0 - (received.to_f * 100 / count))}% packet loss"
    avg = rtt_list.reduce { |a, i| a + i } / received
    stddev = Math.sqrt(rtt_list.map { |rtt| rtt - avg }.reduce { |a, i| a + (i ** 2) } / received)
    puts "round-trip min/avg/max/stddev = #{"%.3f" % rtt_list.min}/#{"%.3f" % avg}/#{"%.3f" % rtt_list.max}/#{"%.3f" % stddev} ms"
  end
end
