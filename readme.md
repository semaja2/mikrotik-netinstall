# Mikrotik Netinstall in a Container

## Overview
This container is designed to run on alternate platforms (eg. ARM/ARM64) and to facilitate a simple netinstall experience

## Enviroment Variables
| Name | Default | Description |
|------|---------|-------------|
| NETINSTALL_ADDR | 192.168.88.1 | Client IP Address for Netinstall to assign |
| NETINSTALL_RESET | `<null>` | Add `-r` to Netinstall arguments (https://help.mikrotik.com/docs/display/ROS/Netinstall#Netinstall-InstructionsforLinux)
| NETINSTALL_ARCH | mipsbe | CPU Architecture to use when selecting npk (Optional) |
| LOAD_VERSION | `<null>` | RouterOS version to use when selecting npk (Optional) |
| NETINSTALL_NPK | `routeros-${NETINSTALL_ARCH}-${LOAD_VERSION}.npk"` | NPK for Netinstall to use |

*Note:* The `-k` and `-s` netinstall arguments are not implemented yet

## Usage on RouterOS v7
With the implementation of containers in ROSv7, we can now enjoy a netinstall experience from another Mikrotik

Testing has been completed with a RB4011 (v7.6b8) running the container to flash a RB2011

### Steps
The below steps will create a container linking to `ether5`, and set netinstall to load the `routeros-mipsbe-6.48.6.npk` NPK file

1. Enable containers and install package (refer wiki)
2. Create folder `images` under `disk1`
3. Upload npk files to images folder
4. Create veth interface 
    ```
    /interface veth add address=192.168.88.6/24 gateway=192.168.88.1 name=veth1
    ```
5. Create bridge
    ```
    /interface bridge add name=dockers
    ```
6. Add veth and physical port to bridge
    ```
    /interface bridge port add bridge=dockers interface=veth1
    /interface bridge port add bridge=dockers interface=ether5
    ```
7. Create mount to contain npk files
    ```
    /container mounts add dst=/app/images name=images src=/disk1/images
    ```
8. Create enviroment set, and specify npk file to use
    ```
    /container envs add key=NETINSTALL_NPK name=NETINSTALL value=routeros-mipsbe-6.48.6.npk
    ```
9. Create container
    ```
    /container add remote-image=semaja2/mikrotik-netinstall:latest envlist=NETINSTALL interface=veth1 logging=yes mounts=images workdir=/app
    ```

## Usage with Podman
>TODO

## Usage with Docker
Due to limitations with Docker, the container can only work via the `--network=host` network parameter, as such this is only useful on Linux as this driver is not available for Windows/MacOS
 > The host networking driver only works on Linux hosts, and is not supported on Docker Desktop for Mac, Docker Desktop for Windows, or Docker EE for Windows Server.

>TODO