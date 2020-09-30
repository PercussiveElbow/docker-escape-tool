require "uri"
require "http/client"
require "../../utils/network/port_scan"
require "socket"
require "uri"

def is_net_mode_host?
    paths = NetSample::NIC.ifnames
    paths.each do | path |
      if path.includes? "docker" 
        puts("\n•  We appear to be sharing the host network stack. We can check for services bound to localhost, these may be running on the host OS.")
        return true
      end
    end
    false
end

def find_network_socket
  section_banner("Checking Network Socket")
  is_net_mode_host?
  url = ""
  paths = NetSample::NIC.ifnames
  paths.each do | path |
    ip = NetSample::NIC.inaddr_of(path)
    puts "\n==> Checking network path #{path} #{ip}"
    if ip
      url = check_network_socket(ip)
      basic_port_scan(ip)
    end
    puts "==> Finished checking network path #{path} #{ip}"

    if url && url.size > 0
      section_banner("Done Checking Network Socket")
      return url
    end

  end
  section_banner("Done Checking Network Socket")
  return ""
end

def check_network_socket(ip)
  default_http_service = check_for_docker_network_socket("http://#{ip}", 2375, false)
  default_https_service = check_for_docker_network_socket("https://#{ip}", 2376, true)
  if default_http_service
    return default_http_service
  elif default_https_service
    return default_https_service
  end
end

def check_for_docker_network_socket(path, port, tls)
  begin 
    uri = URI.parse(path) # parsing isnt picking up port 
    uri.port = port
    return_path = path + ":" + port.to_s
    host_and_port = [return_path,port]
    if tls 
      client = HTTP::Client.new(uri) # todo add check for self signed TLS 
    else 
      client = HTTP::Client.new(uri)
    end
    client = Docker::Client.new(path,port)
    client.list_containers()
    puts("•  Docker Daemon possibly found on #{return_path}".green)
    return host_and_port
  rescue ex
    puts("•  Couldn't find Docker Daemon running on #{return_path}".red)
    puts(ex)
  end
end
