# frozen_string_literal: true

# Make sure Vagrant runs from its base dir
Dir.chdir(__dir__)

# Loading VMs settings hash
require 'yaml'
GLOBAL = YAML.load_file(File.join('etc', 'global.yaml'))
VMS = YAML.load_file(File.join('etc', 'vms.yaml'))

# There we go
Vagrant.configure('2') do |config|
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
    end
  end
end
