module NetSample::Ping
  abstract class Result
    def self.load(echo_request : ICMP::EchoRequest, result : ICMP::Packet | Exception, rtt : Float64 = 0.0)
      if result.is_a?(ICMP::Packet)
        case result.data[1]
        when 0u8
          return EchoReplyReceived.new(echo_request, result, rtt)
        when 3u8
          return DestinationUnreachable.new(echo_request, result, rtt)
        else
          return OtherICMPRecieved.new(echo_request, result, rtt)
        end
      else
        return ExceptionOccur.new(echo_request, result)
      end
    end

    @valid : Bool = false

    def valid?
      @valid
    end

    abstract def message : String
  end

  abstract class ICMPReceived < Result
    getter ip : ICMP::Packet
    getter type : UInt8
    getter code : UInt8
    getter rtt : Float64

    def initialize(@echo_request : ICMP::EchoRequest, @ip : ICMP::Packet, @rtt : Float64)
      @type = @ip.data[0]
      @code = @ip.data[1]
    end
  end

  class EchoReplyReceived < ICMPReceived
    def message
      echo_reply = ICMP::EchoReply.new(@ip.data)
      @valid = (echo_reply == ICMP::EchoReply.from_request(@echo_request))
      if valid?
        "#{@ip.data.size} bytes from #{@ip.dst}: icmp_seq=#{echo_reply.sequence} ttl=#{@ip.ttl} time=#{"%.3f" % @rtt} ms"
      else
        "Data mismatch reply received."
      end
    end
  end

  class DestinationUnreachable < ICMPReceived
    def message
      "Destination Unreachable.(code: #{@code}"
    end
  end

  class OtherICMPRecieved < ICMPReceived
    def message
      "Other ICMP packet received.(type: #{@type}, code: #{@code})"
    end
  end

  class ExceptionOccur < Result
    def initialize(@echo_request : ICMP::EchoRequest, @ex : Exception)
    end

    def message
      "#{@ex.message} (#{@ex.class})"
    end
  end
end
