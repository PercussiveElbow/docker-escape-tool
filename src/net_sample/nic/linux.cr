{% skip_file unless flag?(:linux) %}

lib LibC
  AF_PACKET = 17

  struct SockaddrLl
    sll_family : UShort
    sll_protocol : UInt16
    sll_ifinex : Int
    sll_hatype : UShort
    sll_pkttype : UChar
    sll_halen : UChar
    sll_addr : StaticArray(UChar, 8)
  end

  union IfaIfu
    ifu_broadaddr : Sockaddr*
    ifu_dstaddr : Sockaddr*
  end

  struct Ifaddrs
    ifa_next : Ifaddrs*
    ifa_name : Char*
    ifa_flags : UInt
    ifa_addr : Sockaddr*
    ifa_netmask : Sockaddr*
    ifa_ifu : IfaIfu
    ifa_data : Void*
  end
end

class NetSample::NIC
  private def self.get_nic_info : Hash(String, self)
    nics = Hash(String, self).new { |h, k| h[k] = self.new(k) }
    if LibC.getifaddrs(out ifaddrs) == -1
      raise Errno.new("errno #{Errno.value} on getifaddr()")
    end
    ifap = ifaddrs.as(LibC::Ifaddrs*)
    while ifap
      ifa = ifap.value
      if ifa_addr = ifa.ifa_addr
        if_name = String.new(ifa.ifa_name)
        case ifa_addr.value.sa_family
        when LibC::AF_INET
          ina = ifa_addr.as(LibC::SockaddrIn*).value
          dst = StaticArray(UInt8, LibC::INET_ADDRSTRLEN).new(0)
          addr = ina.sin_addr.s_addr
          LibC.inet_ntop(LibC::AF_INET, pointerof(addr).as(Void*), dst, LibC::INET_ADDRSTRLEN)
          nics[if_name].inaddr = String.new(dst.to_unsafe)
        when LibC::AF_PACKET
          lla = ifa_addr.as(LibC::SockaddrLl*).value
          data = lla.sll_addr.to_slice.clone
          hwaddr = data[0, LibC::IFHWADDRLEN]
          nics[if_name].hwaddr = hwaddr
        end
      end
      ifap = ifa.ifa_next
    end
    LibC.freeifaddrs(ifaddrs)
    nics
  end
end
