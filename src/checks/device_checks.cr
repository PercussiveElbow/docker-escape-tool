
def device_check
    # Device checks
    puts("\n==> Check avaliable devices.")
    storage_device_found = false
    dev_files = Dir.new("/dev")
    if Dir.new("/dev").size > 16
        puts("•  More devices found than expected for a container. Checking for storage devices")
        dev_files.each do |device|
            if device.to_s.includes?("sda")
                puts("•  Mounted storage device found: #{device}")
                storage_device_found = true
            end
        end
    end
    if !storage_device_found
        puts("•  No storage devices found") 
    end
    storage_device_found
end
