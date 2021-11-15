# Docker Escape Tool

[![Actions Status](https://github.com/PercussiveElbow/docker-escape-tool/workflows/Main/badge.svg)](https://github.com/PercussiveElbow/docker-escape-tool/actions)

*Work In Progress*

This tool will help identify if you're in a Docker container and try some quick escape techniques to help assess the security of your containers. 

This tool is focused specifically on Docker escapes though some of the logic may apply to other container runtimes.

I intend to follow this up with a blog post on helping secure your Docker containers, but for some quick advice please see [this checklist](https://github.com/PercussiveElbow/docker-security-checklist).


## Breakout techniques

* Mounted Docker UNIX socket.
* Reachable Docker network socket (on both default port 2375/2376).
* Mountable devices (e.g. host / disk)
* CVE-2019-5736

Additionally, if the tool will conduct a quick port scan of available interfaces if the container appears to share the host network namespace.

#### To add:
* CVE-2019-14271
* CVE-2020–15257
* Capability based breakouts (CAP_SYS_ADMIN,CAP_SYS_MODULE etc.)
* Ability to enumerate containers within the same Docker network to pivot.

## Building

Use a prebuilt binary from [Releases]("https://github.com/PercussiveElbow/docker-escape-tool/releases") or compile yourself using the supplied Dockerfile using latest Crystal on Alpine.

```
shards install
crystal build  --static src/docker-escape.cr
```



## Usage

```
.\docker_escape                             Display usage information.

Checks:
.\docker_escape check                       Determine if the environment is a Docker container.

Automatic escape:
.\docker_escape auto                        Attempt automatic escape. If successful this starts a privileged container with the host drive mounted at /hostOS.

Manual escape techniques:
.\docker_escape unix                        Attempt an escape using a mounted Docker UNIX socket located at /var/run/docker.sock
.\docker_escape network                     Attempt to escape via Docker TCP socket if found on any interfaces. Port scans if network namespace shared with host.
.\docker_escape device                      Attempt to mount and chroot host OS filesystem. (i.e. if container uses --privileged or --device)
.\docker_escape cve-2019-5736  <payload>    Attempt CVE-2019-5736 (runC escape). If successful, this will trigger when a user runs an EXEC command and will corrupt the host runC binary.
```
## Contributing

Apologies for the messy codebase, if you feel like there's something to contribute feel free to open an issue.


## License
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
