
def enumerate_namespaces()
    puts("==> Enumerating namespaces")
    d = Dir.open("/proc/")
    d.each_child do |pid|
        begin
            if Dir.exists?("/proc/#{pid}")  && pid.match(/^\d+$/) && Dir.exists?("/proc/#{pid}/ns/")
                puts("• Checking namespaces of PID #{pid}")
                proc_dir = Dir.open("/proc/#{pid}/ns/")
                proc_dir.each_child do |id|
                    puts(File.readlink("/proc/#{pid}/ns/#{id}"))
                end
            end


            if Dir.exists?("/proc/#{pid}")  && pid.match(/^\d+$/) && Dir.exists?("/proc/#{pid}/root/")
                puts(File.readlink("/proc/#{pid}/root"))
            end

        rescue ex
            puts("! Error checking PID #{pid} namespaces.")
        end
    end
    d.close

end
