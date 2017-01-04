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
* hiera

This module is useful when:
* Puppet agent installation works when prepended with `LD_LIBRARY_PATH= `
* The Puppet service starts and runs normally
* You are unable to run puppet manually without specifying or unsetting `LD_LIBRARY_PATH` and you are unable or unwilling to update `root`'s environment variables

The module will only apply itself to the `osfamily`'s passed in the `apply_os_family` parameter.  By default, this includes `Solaris` and `AIX`.

## Setup

### What puppet_agent_ld_library_path affects

Installs wrapper scripts under `/usr/local/bin` or at a user specified location for the above puppet executables.  When the module is not being applied, the built-in `puppet_enterprise` module will take over ownership of the wrapper files under `/usr/local/bin` and will immediately restore the system as-shipped.  If an alternate directory is used, you can pass `ensure => false` to clean up this directory if required.

This module addresses [PA-437](https://tickets.puppetlabs.com/browse/PA-437).  When this issue is addressed in-product, you should reset your systems to their original states by removing this module from your Puppet Masters.

## Usage
Probably the simplest way to use this module is to create a classification group matching all nodes and then include the `puppet_agent_ld_library_path` class.  When the module is no longer needed, remove the classification group, and then optionally the module.

Alternatively, the following code snipits can be added to your roles and profiles as required.

### Install wrapper scripts into /usr/local/bin
```puppet
include puppet_agent_ld_library_path
```

### Removing the wrapper scripts from /usr/local/bin
_No code required, just make sure the `puppet_agent_ld_library_path` class is no longer present in your classification data_


### Install wrapper scripts to an alternate location
```puppet
class { 'puppet_agent_ld_library_path':
  wrapper_dir => '/place/to/install',
}
```

## Remove wrapper scripts from an alternate location
```puppet
class { 'puppet_agent_ld_library_path':
  ensure      => false,
  wrapper_dir => '/place/to/install',
}
```

### Install wrapper scripts on platforms other then Solaris
```puppet
class { 'puppet_agent_ld_library_path':
  apply_os_family => ['AIX', 'Solaris', 'RedHat'],
}
```
Note: Parameter values are case sensitive.  This example would attempt to fix AIX and Solaris and 'RedHat' systems.


## Reference

### Classes

* `puppet_agent_ld_library_path` - Manages the wrapper files

### Templates

* `templates/wrapper.erb` - Template for wrapper script to install

## Limitations

* Requires BASH
* Takes over ownership of the files (unless alternate directory specified):
  * `/usr/local/bin/puppet`
  * `/usr/local/bin/hiera`
  * `/usr/local/bin/facter`
* Needs to be removed from all systems when [PA-437]( https://tickets.puppetlabs.com/browse/PA-437) addressed in-product
* `/usr/local/bin` directory must already exist

## Development

This module is a customer hotfix and as such, is not actively maintained.
