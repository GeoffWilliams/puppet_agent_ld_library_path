[![Build Status](https://travis-ci.org/GeoffWilliams/puppet_agent_ld_library_path.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet_agent_ld_library_path)
# puppet_agent_ld_library_path

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with puppet_agent_ld_library_path](#setup)
    * [What puppet_agent_ld_library_path affects](#what-puppet_agent_ld_library_path-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_agent_ld_library_path](#beginning-with-puppet_agent_ld_library_path)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module provides a method to install or remove a wrapper script to unset `LD_LIBRARY_PATH` for the executables:

* puppet
* facter
* pe-man
* hiera

This module is useful when:
* Puppet agent installation works when prepended with `LD_LIBRARY_PATH= `
* The Puppet service starts and runs normally
* You are unable to run puppet manually without specifying or unsetting `LD_LIBRARY_PATH` and you are unable or unwilling to update `root`'s environment variables

## Setup

### What puppet_agent_ld_library_path affects

Installs wrapper scripts under `/usr/local/bin` or at a user specified location for the above puppet executables.  Can also remove the wrappers if required, replacing them with the symlinks that the puppet installer usually creates.

This module addresses [PA-437](https://tickets.puppetlabs.com/browse/PA-437).  When this issue is addressed in-product, you should reset your systems to their original states by instructing this puppet module to remove itself.  Once agent changes have been revoked, this module can be removed from your systems entirely.

## Usage

### Install wrapper scripts into /usr/local/bin
```puppet
include puppet_agent_ld_library_path
```

### Removing the wrapper scripts from /usr/local/bin
```puppet
class { 'puppet_agent_ld_library_path':
  ensure => false,
}
```
This will replace the wrappers with the original symlinks

### Install wrapper scripts to an alternate location
```puppet
class { 'puppet_agent_ld_library_path':
  wrapper_dir => '/place/to/install',
}
```

### Install wrapper scripts on platforms other then Solaris
```puppet
class { 'puppet_agent_ld_library_path':
  apply_os_family => ['AIX', 'Solaris'],
}
```
Note: Parameter values are case sensitive


## Reference

### Classes

* `puppet_agent_ld_library_path` - Manages the wrapper files

### Templates

* `templates/wrapper.erb` - Template for wrapper script to install

## Limitations

* Requires BASH
* Takes over ownership of the files (unless alternate directory specified):
  * `/usr/local/bin/puppet`
  * `/usr/local/bin/pe-man`
  * `/usr/local/bin/hiera`
  * `/usr/local/bin/facter`
* Needs to be removed from all systems when [PA-437]( https://tickets.puppetlabs.com/browse/PA-437) addressed in-product

## Development

This module is a customer hotfix and as such, is not actively maintained.
