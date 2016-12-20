# Class: puppet_agent_ld_library_path
# ===========================
#
# Full description of class puppet_agent_ld_library_path here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'puppet_agent_ld_library_path':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class puppet_agent_ld_library_path(
    $ensure           = true,
    $wrapper_dir      = '/usr/local/bin',
    $apply_os_family  = ['Solaris'],
) {
  $targets = [
    'puppet', 'facter', 'pe-man', 'hiera'
  ]

  if $osfamily in $apply_os_family {
    $targets.each |$target| {
      $wrapper_script = "${wrapper_dir}/${target}"
      $real_exe       = "/opt/puppetlabs/bin/${target}"

      if $ensure {
        file { $wrapper_script:
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content => template('puppet_agent_ld_library_path/wrapper.erb'),
        }
      } else {
        if $wrapper_dir == '/usr/local/bin' {
          file { $wrapper_script:
            ensure  => link,
            target  => $real_exe,
            owner   => 'root',
            group   => 'root',
          }
        } else {
          file { $wrapper_script:
            ensure => absent,
          }
        }
      }
    }
  }
}
