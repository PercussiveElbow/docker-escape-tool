
## Leet logo for all the haxx0rz
def logo
    puts %q{
8888888b.                 888                     
888   Y88b                888                     
888    888                888                     
888    888 .d88b.  .d8888b888  888 .d88b. 888d888 
888    888d88  88bd88P    888 .88Pd8P  Y8b888P   
888    888888  888888     888888K 88888888888     
888  .d88PY88..88PY88b.   888  88bY8b.    888     
8888888P    Y88P    Y8888P888  888  Y8888 888       
                                                    
                                                    
                                                    
8888888888                                         
888                                                
888                                                
8888888    d8888b  .d8888b 8888b. 88888b.  .d88b.  
888       88K     d88P         88b888  88bd8P  Y8b 
888        Y8888b.888     .d888888888  88888888888 
888            X88Y88b.   888  888888 d88PY8b.     
8888888888 88888P   Y8888P Y88888888888P    Y8888  
                                    888              
                                    888              
                                    888              
88888888888             888 
    888                 888 
    888                 888 
    888  .d88b.  .d88b. 888 
    888 d88  88bd88  88b888 
    888 888  888888  888888 
    888 Y88..88PY88..88P888 
    888   Y88P    Y88P  888}
    puts("\nMil0Sec - https://github.com/PercussiveElbow")        
end

def usage
    puts %q{
Docker Escape Tool
USAGE: 
.\docker_escape                             Display usage information.

Checks:
.\docker_escape check                       Determine if the environment is a Docker container.

Automatic escape:
.\docker_escape auto                        Attempt automatic escape. If successful this starts a privileged container with the host drive mounted at /hostOS.

Manual escape techniques:
.\docker_escape unix                        Attempt an escape using a mounted Docker UNIX socket located at /var/run/docker.sock
.\docker_escape network                     Attempt to escape via Docker TCP socket if found on any interfaces. Port scans if network namespace shared with host.
.\docker_escape device                      Attempt to mount and chroot host OS filesystem. (i.e. if container uses --privileged or --device)
.\docker_escape cve-2019-5736  <payload>    Attempt CVE-2019-5736 (runC escape). If successful, this will trigger when a user runs an EXEC command and will corrupt the host runC binary.}
end

def section_banner(text)
    puts("\n================================================")
    puts(generate_banner_string(text))
    puts("================================================")
end

def section_banner_green(text)
    puts("\n================================================")
    puts(generate_banner_string(text).green)
    puts("================================================")
end

def section_banner_red(text)
    puts("\n================================================")
    puts(generate_banner_string(text).red)
    puts("================================================")
end

## Funky logic to generate banners at consistent size
def generate_banner_string(text)
    length = 48 - " #{text} ".size()
    pre = "="*((length/2).to_i)
    post = pre
    if (length % 2) != 0
        post += "="
    end
    pre + " #{text} " + post
end
