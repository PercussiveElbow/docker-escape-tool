
def docker_env_init_file_present?
    puts("\n==> Check for Docker Env/Init file.")
    if File.exists?("/.dockerenv")
      puts("•  Docker Env file exists, likely we're in a container built >=1.11".green)
      return true
    elsif File.exists?("/.dockerinit")
      puts("•  Docker Init file exists, likely we're in an old container build pre 1.11".green)
      return true
    end
    puts("•  No docker init/env files found.".red)
    return false
end