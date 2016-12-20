# Class: puppet_agent_ld_library_path
# ===========================
#
# Install or remove wrappers to run puppet agent with LD_LIBRARY_PATH unset
#
# @param ensure True to install the wrappers otherwise false
# @param wrapper_dir Optionally set a path for an alternate directory to install wrappers
# @param apply_os_family Optionall set an array of osfamily to apply on (case sensitive)
class puppet_agent_ld_library_path(
    $ensure           = true,
    $wrapper_dir      = '/usr/local/bin',
    $apply_os_family  = ['Solaris'],
) {
  # include puppet_enterprise::profile::agent
  $targets = [
    'puppet', 'facter', 'pe-man', 'hiera'
  ]

  if $osfamily in $apply_os_family {
    $targets.each |$target| {
      $wrapper_script = "${wrapper_dir}/${target}"
      $real_exe       = "/opt/puppetlabs/bin/${target}"

      if $wrapper_dir == '/usr/local/bin' {
        if ! $puppet_enterprise::profile::agent::manage_symlinks and $ensure {
          # we can only make our changes once the above node group change has been
          # made or we get an error - so wait it out...
          File <| title == $wrapper_script |> {
            ensure  => file,
            owner   => 'root',
            group   => 'root',
            mode    => '0755',
            target  => undef,
            content => template('puppet_agent_ld_library_path/wrapper.erb'),
            require => undef,
          }
        }
      } else {
        $_ensure = $ensure ? {
          true  => 'file',
          false => 'absent'
        }
        file { $wrapper_script:
          ensure  => $_ensure,
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          content => template('puppet_agent_ld_library_path/wrapper.erb'),
        }
      }
    }
  }
}
