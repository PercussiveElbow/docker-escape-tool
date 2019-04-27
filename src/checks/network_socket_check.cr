require "uri"
require "http/client"
require "../utils/net_sample"

lib LibC
  fun getuid : Int 
end

def is_net_mode_host?
    interfaces = NetSample::NIC.ifnames
    interfaces.each do | interface |
      if interface.includes? "docker" 
        puts("We're sharing the host network stack. It's worth checking for services bound to localhost.")
        return true
      end
    end
    false
end

def is_network_socket_present?
  is_net_mode_host?

  interfaces = NetSample::NIC.ifnames
  interfaces.each do | interface |
    ip = NetSample::NIC.inaddr_of(interface)
    puts "Checking interface #{interface} #{ip}"
    if ip
      check_interface_for_socket(ip)
    end
  end
end

def check_interface_for_socket(ip)
  check_network_socket("http://#{ip}:2375/")
  check_network_socket("https://#{ip}:2376/")
end

def check_network_socket(base_url)
  url= base_url + "containers/json"

  begin 
    resp = HTTP::Client.get(url)
    if resp != nil && resp.status_code == 200 && !resp.body.empty?
      puts("Docker daemon possibly found on #{base_url}")
      print_network_socket_banner
      network_socket_breakout(base_url)
    else
      raise("")
    end
  rescue
    puts("Couldn't find docker daemon on #{base_url}")
  end
end

def print_network_socket_banner
  puts("\n================================================")
  puts("========= Docker Network Socket Present ========".green)
  puts("================================================")
end