module NetSample::Ping
  module ICMP
    class ChecksumError < Exception; end

    def self.checksum(data : Bytes)
      io = IO::Memory.new(data.size)
      io.write(data)
      io.rewind
      sum = 0u32
      size = io.size
      read_size = 0
      while size - read_size > 1
        sum += io.read_bytes(UInt16, IO::ByteFormat::NetworkEndian)
        read_size += 2
      end
      unless size == read_size
        sum += io.read_byte.not_nil!
      end
      sum = (sum & 0xffff) + (sum >> 16)
      sum = (sum & 0xffff) + (sum >> 16)
      ~(sum.to_u16)
    end

    def self.checksum!(data : Bytes)
      raise ChecksumError.new unless checksum(data) == 0u16
    end

    class Packet
      getter version : UInt8
      getter protocol : UInt8
      getter ttl : UInt8
      getter src : String
      getter dst : String
      getter data : Bytes

      def initialize(bytes : Bytes)
        @version = (bytes[0] & 0xf0) >> 4
        raise "Non IPv4 packet received." unless version == 4
        ip_header_length = (bytes[0] & 0x0f) * 4
        ip_header = bytes[0, ip_header_length]
        @protocol = ip_header[9]
        raise "Non ICMP packet received." unless protocol == 1
        @ttl = ip_header[8]
        @dst = ip_header[12, 4].join(".")
        @src = ip_header[16, 4].join(".")
        data_length = bytes.size - ip_header_length
        @data = bytes[ip_header_length, data_length]
      end

      def echo_reply?
        data.first == 0u8
      end

      def echo_request?
        data.first == 8u8
      end
    end

    abstract class Data
      getter type : UInt8
      getter code : UInt8
      getter checksum : UInt16

      @type = 0u8
      @code = 0u8
      @checksum = 0u16

      abstract def data(io) : Bytes

      def data
        io = IO::Memory.new(1500)
        data(io)
        io.rewind
        io.to_slice
      end

      def to_bytes
        io = IO::Memory.new(1500)
        io.write_byte(@type)
        io.write_byte(@code)
        io.write_bytes(@checksum, IO::ByteFormat::NetworkEndian)
        data(io)
        io.rewind
        io.to_slice
      end
    end

    abstract class EchoData < Data
      getter id : UInt16
      getter sequence : UInt16
      getter message : String

      def initialize(@id, @sequence, @message)
        @checksum = ICMP.checksum(to_bytes)
      end

      def initialize(bytes : Bytes)
        io = IO::Memory.new(1500)
        io.write(bytes)
        io.rewind
        initialize(io)
      end

      def initialize(io : IO)
        @type = io.read_byte.not_nil!
        @code = io.read_byte.not_nil!
        @checksum = io.read_bytes(UInt16, IO::ByteFormat::NetworkEndian)
        @id = io.read_bytes(UInt16, IO::ByteFormat::NetworkEndian)
        @sequence = io.read_bytes(UInt16, IO::ByteFormat::NetworkEndian)
        @message = io.gets_to_end
        if @checksum == 0u16
          @checksum = ICMP.checksum(to_bytes)
        else
          ICMP.checksum!(to_bytes)
        end
      end

      def data(io : IO)
        io.write_bytes(@id, IO::ByteFormat::NetworkEndian)
        io.write_bytes(@sequence, IO::ByteFormat::NetworkEndian)
        io.write(@message.to_slice)
        while io.size < 64
          io.write_byte(0u8)
        end
      end

      def_equals type, code, checksum, sequence, message
    end

    class EchoRequest < EchoData
      @type : UInt8 = 8u8
    end

    class EchoReply < EchoData
      def self.from_request(req : EchoRequest)
        bytes = req.to_bytes
        bytes[0] = 0u8
        bytes[2] = 0u8
        bytes[3] = 0u8
        self.new(bytes)
      end
    end
  end
end
