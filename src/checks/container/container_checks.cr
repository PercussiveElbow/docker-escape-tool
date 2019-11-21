
def in_container?
  print_banner
  container=false

  checks = [] of Bool
  checks << docker_env_init_file_present?
  checks << docker_in_cgroups?
  checks << processes_like_docker?
  checks << hardware_processes_present?

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
    puts("•  Docker Env file exists, likely we're in a container built >=1.11".green)
    return true
  elsif File.exists?("/.dockerinit")
    puts("•  Docker Init file exists, likely we're in an old container build pre 1.11".green)
    return true
  end
  puts("•  No docker init/env files found.".red)
  return false
end

def docker_in_cgroups?
  puts("\n==> Check for Docker mention in cgroups.")
  if File.exists?("/proc/1/cgroup")
    cgroup_contents = File.new("/proc/1/cgroup").gets_to_end
    puts(cgroup_contents)
    if cgroup_contents.includes?("docker")
      puts("•  Docker mentioned in cgroups. Likely we're in an container".green)
      return true
    end
  end
  puts("•  Docker not mentioned in cgroups. Unlikely we're in a container".red)
  false
end

def processes_like_docker?
  puts("\n==> Check for init process.")
  processes = `ps aux`
  init_process =processes.split("\n")[1]

  common_init_processes=["init","systemd"]
  common_init_found=false
  common_init_processes.each do |common_init_process|
    if init_process.includes?(common_init_process.to_s)
      common_init_found=true
      puts("•  Common init found. This may indicate that we're not in a container, or we're sharing the host PID namespace\n#{init_process}")
      return false
    end
  end
  if !common_init_found
    puts("•  No common init found. Init is:\n#{init_process}")
    return true
  end
  false
end

def hardware_processes_present?
    puts("\n==> Check for hardware processes.")
    processes = `ps aux`
    processes_split = processes.split("\n")
    hardware_processes= ["kthreadd","kswapd0","watchdog","xfsalloc","kintegrityd","khungtaskd","kauditd","mm_percpu_wq","cpuhp"]

    processes_split.each do |process_to_check| 
      hardware_processes.each do |hw_process|
        if process_to_check.to_s.includes?(hw_process)
          print("•  Hardware related process found: #{hw_process}")
          return false
        end
      end
    end
    puts("• No hardware related processes found.") 
    true
end
  