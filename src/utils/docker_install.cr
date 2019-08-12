def docker_install : String
    puts("We're root, let's try and install Docker using the system package manager if avaliable.")
    if !`which apk`.to_s.empty?
      apk_install
    elsif !`which apt`.to_s.empty?
      apt_install
    elsif !`which yum`.to_s.empty?
      yum_install
    end
    if `which docker`.to_s.empty?
      puts("System package manager not avaliable. Let's grab the latest binary straight from docker.com")
      HTTP::Client.get("https://download.docker.com/linux/static/stable/x86_64/docker-18.09.3.tgz") do |response|
         File.write("./docker-18.09.3.tgz", response.body_io)
      end
      `tar xzvf ./docker-18.09.3.tgz`
      return "./docker/docker"
    else
      return "docker"
    end
end

def apk_install
   puts "APK detected"
   puts `apk add docker -y`
end

def apt_install 
   puts "APT detected"
   puts `apt install docker -y`
end

def yum_install
   puts "YUM install.."
   puts `yum install docker -y`
end