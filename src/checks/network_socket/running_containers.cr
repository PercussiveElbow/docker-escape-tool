
def list_running_containers(ip)
    running_containers_banner()
    begin 
        resp = HTTP::Client.get("#{ip}containers/json",  headers: HTTP::Headers{"Content-Type"=> "application/json"})
        if resp != nil && resp.status_code == 200 && !resp.body.empty?
            puts("•  Docker containers found:\n")
            containers = JSON.parse(resp.body).as_h
            if containers.size>0
                containers.each do |container|
                    puts("\nContainer: #{container}")
                end
            end
        else
            raise("Non 200 response on Docker Containers request \n#{resp.body}")
        end
    rescue e
      puts(e)
    end
end

def running_containers_banner
    puts("\n================================================")
    puts("============== List running containers =============".green)
    puts("================================================")
end