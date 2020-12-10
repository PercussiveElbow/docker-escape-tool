
## Iterate through each device, check for block storage devices
def device_check
    section_banner("Mounted Device Check")
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
    puts("•  No mounted storage devices found") if !storage_device_found
    section_banner("Mounted Device Check Done.")
    storage_device_found
end
