require "./utils/*"
require "./checks/*"
require "./breakouts/*"

def main
  logo()
  #user_namespace_enabled=false  

  if ARGV.size>0 
    case ARGV[0].to_s
    when "check"
      in_container?
      auto()
    when "auto"
      in_container?
      auto()
    when "unix"
      attempt_unix_socket_breakout()
    when "network"
      attempt_network_socket_breakout()
    when "device"
      attempt_device_breakout()
    else
      usage()
    end
  else
    usage()
  end
end


def auto
  puts("\n================================================")
  puts("======= Start common breakout techniques =======")
  puts("================================================")
  
  attempt_device_breakout()
  attempt_unix_socket_breakout()
  attempt_network_socket_breakout()
  attempt_capability_breakout()
end

def attempt_device_breakout()
  if device_check
    device_breakout
  end
end

def attempt_capability_breakout()
  if capability_check
    puts("Capability breakout not implemented")
  end
end

def attempt_unix_socket_breakout()
  if unix_socket_present?
    unix_socket_breakout
  end
end

def attempt_network_socket_breakout()
  url = find_network_socket

  if url && url.size>0
    #list_running_containers(url)
    dump_docker_secrets(url)
    network_socket_breakout(url)
  end
end

main()
