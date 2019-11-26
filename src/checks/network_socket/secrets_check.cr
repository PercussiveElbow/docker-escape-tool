
def dump_docker_secrets(ip)
    section_banner_green("Dump Docker Secrets")
    begin 
        resp = HTTP::Client.get("#{ip}secrets",  headers: HTTP::Headers{"Content-Type"=> "application/json"})
        if resp != nil && resp.status_code == 201 && !resp.body.empty?
            puts("Docker secrets found:\n")
            puts(JSON.parse(resp.body))
        else
            raise("Non 200 response on Docker Secrets request \n#{resp.body}")
        end
    rescue e
      puts(e)
    end
end
