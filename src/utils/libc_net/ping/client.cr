module NetSample::Ping
  class Client
    class IllegalReplyReceived < Exception; end

    @socket : Socket
    @host : Socket::IPAddress

    def initialize(host : String)
      @host = Socket::IPAddress.new(host, 0)
      @socket = Socket.new(Socket::Family::INET,
        Socket::Type::RAW,
        Socket::Protocol::ICMP)
      @socket.read_timeout = 5.second
    end

    def ping(id : UInt16, sequence : UInt16, message : String)
      send_icmp = ICMP::EchoRequest.new(id, sequence, message)
      bytes = send_icmp.to_bytes
      begin
        LibC.sendto(@socket.fd, bytes.to_unsafe.as(Void*), bytes.size, 0, @host, @host.size)
        send_time = Time.now
        bytes = Bytes.new(1500)
        bytes_read, _ = @socket.receive(bytes)
      rescue ex
        return Result.load(send_icmp, ex)
      end
      receive_time = Time.now
      rtt = (receive_time - send_time).total_milliseconds
      packet = ICMP::Packet.new(bytes[0, bytes_read])
      return Result.load(send_icmp, packet, rtt)
    end
  end
end
