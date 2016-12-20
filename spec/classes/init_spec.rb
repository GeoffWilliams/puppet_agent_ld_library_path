require 'spec_helper'
describe 'puppet_agent_ld_library_path' do
  default_facts = {
    :osfamily                   => 'Solaris',
    :pe_server_version          => 'x.x.x',
    :platform_symlink_writable  => true,
  }

  pe_base_precondition = '
    class { "puppet_enterprise":
      certificate_authority_host    => "x",
      puppet_master_host            => "x",
      console_host                  => "x",
      puppetdb_host                 => "x",
      database_host                 => "x",
      mcollective_middleware_hosts  => "x",
      pcp_broker_host               => "x",
    }
    '
  let :facts do
    default_facts
  end
  let :pre_condition do
    pe_base_precondition +
    'class { "puppet_enterprise::profile::agent": manage_symlinks=>true }  '
  end

  context 'with default values for all parameters' do
    it { should contain_class('puppet_agent_ld_library_path') }
  end

  context 'enable fix with default settings when puppet_enterprise classified not to manage symlinks' do
    let :pre_condition do
      pe_base_precondition +
      'class { "puppet_enterprise::profile::agent": manage_symlinks=>false }'
    end
    targets = [
      '/usr/local/bin/puppet',
      '/usr/local/bin/facter',
      '/usr/local/bin/pe-man',
      '/usr/local/bin/hiera',
    ]
    it {
      targets.each { |target|
        should contain_file(target).with({
          'ensure'    => 'file',
        })
        should contain_file(target).with_content(/PA-437/)
      }
    }
  end

  context 'creates allows relocating the symlinks' do
    let :params do
      {
        :wrapper_dir => '/zzz',
      }
    end
    targets = [
      '/zzz/puppet',
      '/zzz/facter',
      '/zzz/pe-man',
      '/zzz/hiera',
    ]
    it {
      targets.each { |target|
        should contain_file(target).with({
          'ensure'    => 'file',
        })
        should contain_file(target).with_content(/PA-437/)
      }
    }
  end

  context 'does not manage the target files when ensure=>false' do
    let :params do
      {
        :ensure => false,
      }
    end
    targets = [
      '/usr/local/bin/puppet',
      '/usr/local/bin/facter',
      '/usr/local/bin/pe-man',
      '/usr/local/bin/hiera',
    ]
    it {
      targets.each { |target|
        should_not contain_file(target)
      }
    }
  end

  context 'removes the wrapper script when non-default wrapper dir in use' do
    let :params do
      {
        :ensure => false,
        :wrapper_dir => '/zzz',
      }
    end
    targets = [
      '/zzz/puppet',
      '/zzz/facter',
      '/zzz/pe-man',
      '/zzz/hiera',
    ]
    it {
      targets.each { |target|
        should contain_file(target).with({
          'ensure'    => 'absent',
        })
      }
    }
  end

  context 'does not apply on non solaris by default' do
    let :facts do
      default_facts.merge({:osfamily => 'RedHat'})
    end
    targets = [
      '/usr/local/bin/puppet',
      '/usr/local/bin/facter',
      '/usr/local/bin/pe-man',
      '/usr/local/bin/hiera',
    ]
    it {
      targets.each { |target|
        should_not contain_file(target)
      }
    }
  end

  context 'applies on other platforms' do
    let :params do
      {
        :ensure           => true,
        :apply_os_family  => ['Solaris', 'AIX'],
      }
    end
    let :facts do
      default_facts.merge({:osfamily => 'AIX'})
    end
    targets = [
      '/usr/local/bin/puppet',
      '/usr/local/bin/facter',
      '/usr/local/bin/pe-man',
      '/usr/local/bin/hiera',
    ]
    it {
      targets.each { |target|
        should_not contain_file(target)
      }
    }
  end

  context 'classifies master when ensure=>true' do
    it { should contain_node_group('PE Agent').with({
      'classes' => {'puppet_enterprise::profile::agent' => {'manage_symlinks' => false}},
    })}
  end

  context 'removes classification from master when ensure=>false' do
    let :params do
      {
        'ensure' => false,
      }
    end
    it { should contain_node_group('PE Agent').with({
      'classes' => {'puppet_enterprise::profile::agent' => {'manage_symlinks' => true}},
    })}
  end

  context 'does not classify on agents' do
    let :facts do
      # have set the fact to false instead of omiting it becase
      # rspec tests with strict variables on
      default_facts.merge({:pe_server_version => false})
    end
    it { should_not contain_node_group('PE Agent') }
  end
end
