require "uri"
require "http/client"
require "../../utils/network/net_sample"
require "../../utils/network/port_scan"
require "socket"


def is_net_mode_host?
    interfaces = NetSample::NIC.ifnames
    interfaces.each do | interface |
      if interface.includes? "docker" 
        puts("\n•  We appear to be sharing the host network stack. We can check for services bound to localhost, these may be running on the host OS.")
        return true
      end
    end
    false
end

def find_network_socket
  network_socket_check()
  is_net_mode_host?
  url = ""
  interfaces = NetSample::NIC.ifnames
  interfaces.each do | interface |
    ip = NetSample::NIC.inaddr_of(interface)
    puts "\n==> Checking network interface #{interface} #{ip}"
    if ip
      url = check_network_socket(ip)
      basic_port_scan(ip)
    end
    puts "==> Finished checking network interface #{interface} #{ip}"

    if url && url.size > 0
      network_socket_check_finished()
      return url
    end

  end
  network_socket_check_finished()
  return ""
end

def check_network_socket(ip)
  default_http = check_for_docker_network_socket("http://#{ip}:2375/")
  default_https = check_for_docker_network_socket("https://#{ip}:2376/")
  if default_http!=nil && default_http.size>0
    return default_http
  elif default_https!=nil && default_https.size>0
    return default_https
  else
    return ""
  end
end

def check_for_docker_network_socket(base_url)
  url= base_url + "containers/json"

  begin 
    resp = HTTP::Client.get(url)
    if resp != nil && resp.status_code == 200 && !resp.body.empty?
      puts("•  Docker Daemon possibly found on #{base_url}".green)
      return base_url
    else
      return ""
    end
  rescue
    puts("•  Couldn't find Docker Daemon running on #{base_url}".red)
    return ""
  end
end

def network_socket_check
  puts("\n================================================")
  puts("=========== Checking Network Socket  ===========")
  puts("================================================")
end

def network_socket_check_finished
  puts("\n================================================")
  puts("========= Done Checking Network Socket  ========")
  puts("================================================")
end