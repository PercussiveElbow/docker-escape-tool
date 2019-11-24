require "./utils/*"
require "./checks/*"
require "./breakouts/*"

def main
  logo()

  #user_namespace_enabled=false
  
  if ARGV.size>0 && ARGV[0].to_s =="auto"
    container=in_container?
    breakout()
  elsif ARGV.size>0 && ARGV[0].to_s =="check"
    container=in_container?
  else
    usage()
  end
end

def breakout
  puts("\n================================================")
  puts("======= Start common breakout techniques =======")
  puts("================================================")

  if device_check
    device_breakout
  end
  
  if unix_socket_present?
    unix_socket_breakout
  end
  
  url = find_network_socket

  if url && url.size>0
    #list_running_containers(url)
    dump_docker_secrets(url)
    network_socket_breakout(url)
  end
end

main()
