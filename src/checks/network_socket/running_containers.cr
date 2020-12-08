
## List the running containers
## TODO: Unused currently. Replace this with the actual Docker client.
def list_running_containers(ip)
    section_banner_green("List running containers")
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
