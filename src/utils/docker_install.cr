def docker_install : String
    puts("We're root, let's try and install Docker using the system package manager if avaliable.")
    if !`which apk`.to_s.empty?
       puts "APK detected"
       puts `apk add docker`
    elsif !`which apt`.to_s.empty?
       puts "APT detected"
       puts `apt install docker`
    elsif !`which yum`.to_s.empty?
       puts "YUM install.."
       puts `yum install docker`
    end
    if `which docker`.to_s.empty?
      puts("System package manager not avaliable. Let's grab the latest binary straight form docker.com")
      HTTP::Client.get("https://download.docker.com/linux/static/stable/x86_64/docker-18.09.3.tgz") do |response|
         File.write("./docker-18.09.3.tgz", response.body_io)
      end
      `tar xzvf ./docker-18.09.3.tgz`
      return "./docker/docker"
    else
      return "docker"
    end
end
