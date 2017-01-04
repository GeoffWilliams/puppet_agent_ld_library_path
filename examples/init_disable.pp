$group = $osfamily ? {
  'AIX'   => 'system',
  default => 'root'
}

['puppet', 'facter', 'hiera'].each |$binary| {
  file { "/usr/local/bin/${binary}":
    ensure  => link,
    target  => "/opt/puppetlabs/bin/${binary}",
    owner   => 'root',
    group   => $group,
  }
}

class { 'puppet_agent_ld_library_path':
  ensure => false,
}
