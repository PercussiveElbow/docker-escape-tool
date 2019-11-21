require "./checks/*"
require "./utils/*"
require "./breakouts/*"

puts %q{
8888888b.                 888                     
888   Y88b                888                     
888    888                888                     
888    888 .d88b.  .d8888b888  888 .d88b. 888d888 
888    888d88  88bd88P    888 .88Pd8P  Y8b888P   
888    888888  888888     888888K 88888888888     
888  .d88PY88..88PY88b.   888  88bY8b.    888     
8888888P    Y88P    Y8888P888  888  Y8888 888       
                                                  
                                                  
                                                  
8888888888                                         
888                                                
888                                                
8888888    d8888b  .d8888b 8888b. 88888b.  .d88b.  
888       88K     d88P         88b888  88bd8P  Y8b 
888        Y8888b.888     .d888888888  88888888888 
888            X88Y88b.   888  888888 d88PY8b.     
8888888888 88888P   Y8888P Y88888888888P    Y8888  
                                  888              
                                  888              
                                  888              
88888888888             888 
    888                 888 
    888                 888 
    888  .d88b.  .d88b. 888 
    888 d88  88bd88  88b888 
    888 888  888888  888888 
    888 Y88..88PY88..88P888 
    888   Y88P    Y88P  888}

def main
  user_namespace_enabled=false
  container=in_container?
  if ARGV.size>0 && ARGV[0].to_s =="escape"
    breakout()
  elsif ARGV.size>0
    usage
  end
end

def usage 
  puts("Docker Escape Tool\nUsage:\n\".\\docker_escape escape\" to attempt escape")
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
    dump_docker_secrets(url)
    network_socket_breakout(url)
  end
end

main()
