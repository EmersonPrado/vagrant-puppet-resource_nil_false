# vagrant-puppet-resource_nil_false

Vagrant environment to test Puppet custom resources failure with properties set to `unset` or `false`

#### Contents

1. [Description](#description)
1. [Usage](#usage)
    1. [Download project](#download-project)
    1. [Virtual machines](#virtual-machines)
        1. [Debian 9 VM fix](#debian-9-vm-fix)

## Description

This project automates the creation of an environment to test Puppet custom resources created with low level method.

It was observed that, when such resources properties are set to `unset` or `false`, Puppet just doesn't call the properties setter functions.

This Vagrant environment includes a set of VMs with varied distros and versions, a test Puppet module with a dummy custom resource and a main manifest calling this resource.

## Usage

### Download project

If you didn't already, clone this project locally

```Shell
cd <Parent directory>
git clone https://github.com/EmersonPrado/vagrant-puppet-resource_nil_false.git
cd vagrant-puppet-resource_nil_false
```

If you already cloned, update it

```Shell
cd <Local clone dir>
git pull
```

### Virtual machines

Vagrant manages the VMs. You can query and change their statuses via `vagrant <Command> [<Options>] [VMs]`. Examples:


```Shell
# Check VMs statuses
vagrant status [ <VM spec> ]
# Turn VMs on, creating if necessary
vagrant up [ --no-provision ] [ <VM spec> ]
# Run provisioner(s) inside VMs
vagrant provision [ --provision-with=<Provisioner> ] [ <VM spec> ]
# Run shell in a VM
vagrant ssh <VM name>
# Run command in a VM (watch your quotes!)
vagrant ssh <VM name> -c <Command>
# Turn VMs off
vagrant halt [ <VM spec> ]
# Remove VMs, turning off if necessary
vagrant destroy [ <VM spec> ]
```

Where:
- VM spec: list of space-separated names and/or regular expressions to match names
    - Default: all
- `--no-provision`: don't run provisioners
- Provisioner: `shell` installs Puppet and `puppet` runs the main manifest
    - Default: all

#### Debian 9 VM fix

VM `debian-09` will fail when created, because of an incompatibility between the OS and VirtualBox Guest Additions versions. To fix it, update APT repos, then the SO, then the kernel:

```Shell
# In your host
vagrant ssh debian-09
# Inside the VM
echo 'deb http://deb.debian.org/debian stretch-backports main contrib' |
  sudo tee -a /etc/apt/sources.list > /dev/null
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -yt stretch-backports install linux-{headers,image}-amd64
exit
# In your host
vagrant reload --no-provision debian-09     # Loads updated kernel
vagrant vbguest --do install -b debian-09   # Updates Guest Additions
vagrant reload debian-09                    # Loads updated Guest Additions
```
