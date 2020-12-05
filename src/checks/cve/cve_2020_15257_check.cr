
def cve_2020_15257_check() 
    puts("==> CVE-2020-1527 check - Looking for abstract socket mentioning containerd")
    begin
        File.open("/proc/net/unix").each_line do | line | 
            if line.includes?("@/containerd")
                puts("•  Container vulnerable to CVE-2020-1527. Found the following abstract socket: ")
                puts(line)
                return true
            end
        end
    rescue ex
        puts("! Error checking for CVE-2020-15257.")
    end
    puts("•  No mentions of containerd in abstract sockets, host does not appear vulnerable to CVE-2020-1527")
    false
end