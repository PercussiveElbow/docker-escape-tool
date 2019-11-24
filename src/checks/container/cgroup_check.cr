
def docker_in_cgroups?
    puts("\n==> Check for Docker mention in cgroups.")
    if File.exists?("/proc/1/cgroup")
      cgroup_contents = File.new("/proc/1/cgroup").gets_to_end
      puts(cgroup_contents)
      if cgroup_contents.includes?("docker")
        puts("•  Docker mentioned in cgroups. Likely we're in an container".green)
        return true
      end
    end
    puts("•  Docker not mentioned in cgroups. Unlikely we're in a container".red)
    false
end