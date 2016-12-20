require 'spec_helper'
describe 'puppet_agent_ld_library_path' do
  let :facts do
    {
      :osfamily => 'Solaris',
    }
  end

  context 'with default values for all parameters' do
    it { should contain_class('puppet_agent_ld_library_path') }
  end

  context 'enable fix with default settings' do
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

  context 'reinstates the original links on removal with default params' do
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
        should contain_file(target).with({
          'ensure'    => 'link',
          'target'    => "/opt/puppetlabs/bin/#{File.basename(target)}"
        })
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
      {
        :osfamily => 'RedHat',
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

  context 'applies on other platforms when specified' do
    let :params do
      {
        :ensure           => false,
        :apply_os_family  => ['Solaris', 'AIX'],
      }
    end
    let :facts do
      {
        :osfamily => 'AIX',
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
        should contain_file(target)
      }
    }
  end

end
