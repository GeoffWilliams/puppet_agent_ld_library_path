# simulate the file resources that puppet_enterprise module creates for us so
# that module can override them
$group = $osfamily ? {
  'AIX'   => 'system',
  default => 'root',
}
['puppet', 'facter', 'hiera'].each |$binary| {
  file { "/usr/local/bin/${binary}":
    ensure  => link,
    target  => "/opt/puppetlabs/bin/${binary}",
    owner   => 'root',
    group   => $group,
  }
}

include ::puppet_agent_ld_library_path
