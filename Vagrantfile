# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure('2') do |config|

  # Define base image
  config.vm.box = 'ubuntu/trusty64'

  # Manage /etc/hosts on host and VMs
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true
  config.hostmanager.ignore_private_ip = false

  if Vagrant.has_plugin? ('omnibus')
    config.omnibus.chef_version = 'latest'
  end

  config.berkshelf.enabled = true

  config.vm.define :rabbit1 do |rabbit1|
    rabbit1.vm.network :private_network, ip: '10.211.11.100'
    rabbit1.vm.hostname = 'rabbit1'
    rabbit1.vm.provision :hostmanager
    config.vm.provision 'chef_solo' do |chef|
      chef.roles_path = 'roles'
      chef.add_role('rabbitmq')
      chef.add_role('rabbitmq_master')
    end
  end

  config.vm.define :rabbit2 do |rabbit2|
    rabbit2.vm.network :private_network, ip: '10.211.11.101'
    rabbit2.vm.hostname = 'rabbit2'
    rabbit2.vm.provision :hostmanager
    rabbit2.vm.provision 'chef_solo' do |chef|
      chef.roles_path = 'roles'
      chef.json = {
          'rabbitmq-cluster' => {
              'cluster_node_type' => 'disc'
          }
      }
      chef.add_role('rabbitmq')
      chef.add_role('rabbitmq_slave')
    end
  end

  config.vm.define :rabbit3 do |rabbit3|
    rabbit3.vm.network :private_network, ip: '10.211.11.102'
    rabbit3.vm.hostname = 'rabbit3'
    rabbit3.vm.provision :hostmanager
    rabbit3.vm.provision 'chef_solo' do |chef|
      chef.roles_path = 'roles'
      chef.json = {
          'rabbitmq-cluster' => {
              'cluster_node_type' => 'ram'
          }
      }
      chef.add_role('rabbitmq')
      chef.add_role('rabbitmq_slave')
    end
  end

end