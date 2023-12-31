# frozen_string_literal: true

# Make sure Vagrant runs from its base dir
Dir.chdir(__dir__)

# Loading VMs settings hash
require 'yaml'
GLOBAL = YAML.load_file(File.join('etc', 'global.yaml'))
VMS = YAML.load_file(File.join('etc', 'vms.yaml'))

# Hiera host dir
Dir.mkdir('data') unless Dir.exist?('data')

# There we go
Vagrant.configure('2') do |config|
  # Avoid user-unexpected steps at "vagrant up"
  config.vbguest.auto_update = false if Vagrant.has_plugin?('vagrant-vbguest')

  # Puppet provisioner mounts needed dirs, except this
  config.vm.synced_folder 'data', '/tmp/vagrant-hiera' do |folder|
    folder.id = 'hiera_dir'
  end

  VMS.each do |name, confs|
    config.vm.define name do |vm|
      vm.vm.box = confs[:box]

      # VirtualBox specific settings
      vm.vm.provider 'virtualbox' do |virtualbox|
        virtualbox.memory = GLOBAL[:ram]
        virtualbox.cpus = GLOBAL[:cpu]
        GLOBAL[:custom].each do |key, value|
          virtualbox.customize ['modifyvm', :id, key, value]
        end
      end

      # Puppet installation
      vm.vm.provision :shell do |shell|
        shell.name = 'Installs Puppet'
        shell.path = 'bin/install_puppet.sh'
        # Set Puppet Version in file etc/global.yaml
        shell.args = GLOBAL[:puppet_version]
      end

      # Puppet run
      vm.vm.provision :puppet do |puppet|
        puppet.binary_path = '/opt/puppetlabs/bin' if confs[:box].include?('suse')
        puppet.manifests_path = 'manifests'
        puppet.module_path = 'modules'
        # Uncomment if debug needed
        # puppet.options = ['-d']
        puppet.hiera_config_path = 'hiera.yaml'
        puppet.working_directory = '/tmp/vagrant-puppet'
      end
    end
  end
end
