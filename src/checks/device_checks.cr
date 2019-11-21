
def device_check
    device_check_banner()
    puts("==> Checking avaliable devices.")
    storage_device_found = false
    dev_files = Dir.new("/dev")
    if Dir.new("/dev").size > 20
        puts("•  More devices found than expected for a container. Checking for storage devices")
        dev_files.each do |device|
            if device.to_s.includes?("sda")
                puts("•  Mounted storage device found: #{device}")
                storage_device_found = true
            end
        end
    end
    puts("•  No storage devices found") if !storage_device_found
    puts("==> Finished checking avaliable devices.")
    return storage_device_found
end

def device_check_banner
    puts("\n================================================")
    puts("============= Mounted Device Check  ============")
    puts("================================================")
  end
