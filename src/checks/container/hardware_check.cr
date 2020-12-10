
## This method iterates /proc/ looking for common hardware related processes
## Returns true if at least one found, otherwise false
def hardware_processes_present?
    section_banner("Hardware Devices Check")

    hardware_processes= ["kthreadd","kswapd0","watchdog","xfsalloc","kintegrityd","khungtaskd","kauditd","mm_percpu_wq","cpuhp"]
    d = Dir.open("/proc/")
    d.each_child do |pid|
        begin
            if Dir.exists?("/proc/#{pid}")  && pid.match(/^\d+$/) && File.exists?("/proc/#{pid}/status")
                # Check status as hacky fix. Some process names don't appear in /proc/*/cmdline
                cmdline = File.read_lines("/proc/#{pid}/status")[0]
                hardware_processes.each do |hw_process|
                    if cmdline.to_s.includes?(hw_process)
                        print("•  Hardware related process found: #{hw_process}")
                        return false
                    end
                end
            end
        rescue ex 
        end
    end
    puts("• No hardware related processes found. This indicates we may be in a container.")
    section_banner("Done Hardware Devices Check")
    true
end
