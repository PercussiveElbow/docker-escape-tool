require "uri"
require "http/client"

def is_net_mode_host?
    interfaces = NetSample::NIC.ifnames
    interfaces.each do | interface |
      if interface.includes? "docker" 
        puts("We're sharing the host network stack. It's worth nmap scanning localhost. We'll check for docker ports on 3275/6 now")
        return true
      end
    end
    false
end

def is_docker_net_socket_reachable?
  interfaces = NetSample::NIC.ifnames
  puts interfaces
  interfaces.each do | interface |
    puts NetSample::NIC[interface]
  end
end

def check_interface_for_socket(ip)
  protocol = "http://"
  url="#{ip}:2375/containers/json"
  sample_url = protocol + url
  resp = HTTP::Client.get(sample_url)
  if resp != nil && resp.status_code == 200 && !resp.body.empty?
    puts resp.body
  end
end
