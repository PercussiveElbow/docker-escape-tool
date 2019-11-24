
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
