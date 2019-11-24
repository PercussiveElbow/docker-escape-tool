
def processes_like_docker?
    puts("\n==> Check for init process.")
    processes = `ps aux`
    init_process =processes.split("\n")[1]
  
    common_init_processes=["init","systemd"]
    common_init_found=false
    common_init_processes.each do |common_init_process|
      if init_process.includes?(common_init_process.to_s)
        common_init_found=true
        puts("•  Common init found. This may indicate that we're not in a container, or we're sharing the host PID namespace.\n#{init_process}")
        return false
      end
    end
    if !common_init_found
      puts("•  No common init found. Init is:\n#{init_process}")
      return true
    end
    false
  end