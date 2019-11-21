require "socket"

def basic_port_scan(ip)
  total_ports=65000
  split = 4
  puts("•  Commencing port scan of #{ip} interface: Ports 1-#{total_ports} across #{split} workers.")

  channel = Channel(Nil).new

  elapsed_time = Time.measure do
    split.times do |i|
      start = (total_ports//split)*i
      finish = (total_ports//split)*(i+1)
      #puts("Starting chunk #{start} to #{finish}")
      spawn scan_chunk(channel,ip,start,finish)
    end

    total_ports.times do
      channel.receive
    end

  end
  puts("•  Finished port scan of #{ip} interface. Time: #{elapsed_time}")
end

def scan_chunk(channel,ip,start,finish)
(start..finish).each do |port|
  begin
    sock = Socket.tcp(Socket::Family::INET)
    sock.connect(ip, port)
    puts("•  Port open on interface #{ip}: #{port}\n")
    channel.send(nil)
  rescue ex
    channel.send(nil)
  end
end

end