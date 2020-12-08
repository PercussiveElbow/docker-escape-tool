
## This process checks for abstract sockets associated with containerd
## If one is found, system is likely vuln so we return true
def cve_2020_15257_check()
    section_banner("CVE-2020-1527 Check")
    puts("==> Looking for abstract socket mentioning containerd")
    begin
        File.open("/proc/net/unix").each_line do |line|
            if line.includes?("@/containerd")
                puts("•  Container vulnerable to CVE-2020-1527. Found the following abstract socket: ")
                puts(line)
                section_banner_green("Host likely vuln to CVE-2020-1527")
                return true
            end
        end
    rescue ex
        puts("! Error checking for CVE-2020-15257.")
    end
    puts("•  No mentions of containerd in abstract sockets, host does not appear vulnerable to CVE-2020-1527".red)
    section_banner_red("Done CVE-2020-1527 Check")
    false
end
