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

def is_net_socket_present?
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
  check_http_socket(ip)
  check_https_socket(ip)
end

def check_http_socket(ip)
  url="http://#{ip}:2375/containers/json"

  begin 
    resp = HTTP::Client.get(url)
    if resp != nil && resp.status_code == 200 && !resp.body.empty?
      puts("Docker daemon possibly found on http://#{ip}:2375")
    else
      raise("")
    end
  rescue
    puts("Couldn't find docker daemon on http://#{ip}:2375")
  end
end

def check_https_socket(ip)
  url = "https://#{ip}:2376/containers/json"
  begin
    resp = HTTP::Client.get(url)
    if resp != nil && resp.status_code == 200 && !resp.body.empty?
      puts("Docker daemon possibly found on https://#{ip}:2376")
    else
      raise("")
    end
  rescue 
    puts("Couldn't find docker daemon on https://#{ip}:2376")
  end
end