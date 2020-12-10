
## Checks for the Docker Unix socket in the default location
## Returns true if found 
def unix_socket_present?
    present=File.exists?("/var/run/docker.sock")
    if present
      section_banner_green("Docker UNIX Socket Present")
    else
      section_banner_red("Docker UNIX Socket Not Present")
    end
    present
end
