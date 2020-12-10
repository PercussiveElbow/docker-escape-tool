
## This method checks for common init process names associated with PID 1
## If no common init is mentioned, we assume we're in a container and return true
def processes_like_docker?
    section_banner("Init Process Check")
    common_init_found=false
    common_init_processes=["init","systemd"]

    if File.exists?("/proc/1/cmdline")
        init_process = File.new("/proc/1/cmdline").gets_to_end
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
    else
        puts("•  No file found at /proc/1/cmdline. Might be in a chroot or similar.")
        return false
    end
    section_banner("Done Init Process Check")
    false
end
