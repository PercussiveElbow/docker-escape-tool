require "bit_array"

CAP_CONSTANTS = [
    "CAP_CHOWN",
    "CAP_DAC_OVERRIDE",
    "CAP_DAC_READ_SEARCH",
    "CAP_FOWNER",
    "CAP_FSETID",
    "CAP_KILL",
    "CAP_SETGID",
    "CAP_SETUID",
    "CAP_SETPCAP",
    "CAP_LINUX_IMMUTABLE",
    "CAP_NET_BIND_SERVICE",
    "CAP_NET_BROADCAST",
    "CAP_NET_ADMIN",
    "CAP_NET_RAW",
    "CAP_IPC_LOCK",
    "CAP_IPC_OWNER",
    "CAP_SYS_MODULE",
    "CAP_SYS_RAWIO",
    "CAP_SYS_CHROOT",
    "CAP_SYS_PTRACE",
    "CAP_SYS_PACCT",
    "CAP_SYS_ADMIN",
    "CAP_SYS_BOOT",
    "CAP_SYS_NICE",
    "CAP_SYS_RESOURCE",
    "CAP_SYS_TIME",
    "CAP_SYS_TTY_CONFIG",
    "CAP_MKNOD",
    "CAP_LEASE",
    "CAP_AUDIT_WRITE",
    "CAP_AUDIT_CONTROL",
    "CAP_SETFCAP",
    "CAP_MAC_OVERRIDE",
    "CAP_MAC_ADMIN",
    "CAP_SYSLOG",
    "CAP_WAKE_ALARM",
    "CAP_BLOCK_SUSPEND",
    "CAP_AUDIT_READ",       
]

def capability_check
    section_banner("Capabilities Check")
    puts("==> Checking avaliable capabilities.")
    cap_string = capability_load()
    capability_parse(cap_string)
    section_banner("Done Checking Capabilities")
end

def capability_parse(cap_string)
    puts("•  Loaded capability #{cap_string}")
    cap_binary = cap_string.to_i64(base: 16).to_s(base: 2)
    present_caps = [] of String

    puts("==> Capabilities present:")
    (0..CAP_CONSTANTS.size-1).each do |i|
        if cap_binary[cap_binary.size-i-1].to_i==1
            present_caps << CAP_CONSTANTS[i]
        end
    end

    present_caps.each do |present_cap|
        puts("•  #{present_cap}")
    end

    present_caps
end

def capability_load
    if File.exists?("/proc/self/status")
        self_proc_status = File.new("/proc/self/status").gets_to_end
        puts(self_proc_status)

        self_proc_status_contents =  self_proc_status.split("\n")

        cap_inh = ""
        cap_prm = ""
        cap_eff = ""
        cap_bnd = ""
        cap_amb = ""
        self_proc_status_contents.each do | line|
            if line.includes?("CapInh") || line.includes?("CapPrm") || line.includes?("CapEff") || line.includes?("CapBnd") || line.includes?("CapAmb")
                field = line.split(":")[0]
                value = line.split(":")[1].sub(/[^0-9a-z ]/, "")
                case field
                when "CapInh"
                    cap_inh = value
                when "CapPrm"
                    cap_prm = value
                when "CapEff"
                    cap_eff = value
                when "CapBnd"
                    cap_bnd = value
                when "CapAmb"
                    cap_amb = value
                end
            end
        end
        if cap_inh
            return cap_inh
        end
    else
        puts("•  Couldn't read /proc/self/status. Might be in a chroot.")
    end
    ""
end
