
def unix_socket_present?
    present=File.exists?("/var/run/docker.sock")
    if present
      puts("\n================================================")
      puts("========== Docker UNIX Socket Present ==========".green)
      puts("================================================")
    end
    present
end