# frozen_string_literal: true

# Make sure Vagrant runs from its base dir
Dir.chdir(__dir__)

# Loading VMs settings hash
require 'yaml'
GLOBAL = YAML.load_file(File.join('etc', 'global.yaml'))
VMS = YAML.load_file(File.join('etc', 'vms.yaml'))
