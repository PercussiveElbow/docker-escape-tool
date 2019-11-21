# Docker Escape Tool

[![Actions Status](https://github.com/PercussiveElbow/docker-escape-tool/workflows/.github/workflows/main.yml/badge.svg)](https://github.com/PercussiveElbow/docker-escape-tool/actions)

WIP

This is a quick script to identify if you're in a Docker container and try some quick escape techniques. 

## Todo
* Refactor literally everything.
* Move from relying on libcurl to Crystal's inbuilt networking once it gains support for unix sockets.
* Improve installing Docker inside a container because currently I'm wgetting a binary lol. 

## Checks
This script assesss if you're in a container through the following:
* Presence of .dockerenv/.dockerinit files
* Mentions of Docker in cgroups
* Weird PID 1 (i.e. not an init)

### To add:
* Lack of hardware related processes
## Breakout techniques

* Mounted Docker unix socket.
* Reachable Docker network socket.
* Mountable devices (e.g. host / disk)

#### To add:
* CVE-2019-5736
* Enumerate containers within the same Docker network to pivot


## Usage

Use a prebuilt binary from the [releases]("/releases") page or compile yourself with:

```
crystal build src/docker-escape.cr
```
Then just run the compiled binary in your container. 