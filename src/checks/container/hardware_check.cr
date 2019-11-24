
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
    puts("• No hardware related processes found. This indicates we may be in a container.") 
    true
end