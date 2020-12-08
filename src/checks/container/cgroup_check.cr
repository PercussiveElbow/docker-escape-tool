

## This method checks if docker is mentioned in our PID cgroup in /proc/
## Returns true if so, otherwise false
def docker_in_cgroups?()
    section_banner("cgroups Check")
    puts("\n==> Check for Docker mention in cgroups.")
    if File.exists?("/proc/self/cgroup")
        cgroup_contents = File.new("/proc/self/cgroup").gets_to_end
        puts(cgroup_contents)
        if cgroup_contents.includes?("docker")
            puts("•  Docker mentioned in cgroups. Likely we're in an container".green)
            return true
        end
    end
    puts("•  Docker not mentioned in cgroups. Unlikely we're in a container".red)
    section_banner("Done cgroups Check")
    false
end
