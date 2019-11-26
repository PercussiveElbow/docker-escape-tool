
def in_container?
  section_banner("Check if we're in a container")
  container=false

  checks = [] of Bool
  checks << docker_env_init_file_present?
  checks << docker_in_cgroups?
  checks << processes_like_docker?
  checks << hardware_processes_present?

  checks.each do |check|
    if check
      container=true
      break
    end
  end
  
  if container
    section_banner_green("We're in a container")
  else
    section_banner_red("We're not in a container")
  end
  container
end