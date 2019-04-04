def in_container?
  print_banner
  container=false

  checks = [] of Bool
  checks << docker_env_init_file_present?
  checks << docker_in_cgroups?
  checks << processes_like_docker?

  checks.each do |check|
    if check
      container=true
      break
    end
  end
  
  container_print = container ? "========== We're in a container ================".green : "======== We're not in a container ==============".red
  puts("\n================================================\n" + container_print + "\n================================================\n")
  container
end

def print_banner
  puts("\n================================================")
  puts("=========Check if we're in a container==========")
  puts("================================================")
end

def docker_env_init_file_present?
  puts("\n==> Check for Docker Env/Init file.")
  if File.exists?("/.dockerenv")
    puts("•  Docker Env file exists, likely we're in a container built >=1.11")
    return true
  elsif File.exists?("/.dockerinit")
    puts("•  Docker Init file exists, likely we're in an old container build pre 1.11")
    return true
  end
  puts("•  No docker init/env files found.")
  return false
end

def docker_in_cgroups?
  puts("\n==> Check for cgroups.")
  if File.exists?("/proc/1/cgroup") && File.new("/proc/1/cgroup").gets_to_end.includes?("docker")
    puts("•  Docker mentioned in cgroups. Likely we're in an container")
    return true
  end
  puts("•  No Docker mentioned in cgroups. Unlikely we're in a container")
  false
end

def processes_like_docker?
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
    puts("•  No common init found. Init is:\n#{init_process}")
    return true
  end
  puts("•  Common init found.")
  false
end

def device_check
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
end