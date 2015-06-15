#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise_service/service_mixin'
require_relative 'helpers'

class Chef::Resource::RabbitmqService < Chef::Resource
  include Poise
  provides(:rabbitmq_service)
  include PoiseService::ServiceMixin

  attribute(:cluster_name, kind_of: String, name_attribute: true)
  attribute(:cluster_role_type, equal_to: %w{master slave}, default: 'slave')
  attribute(:cluster_node_type, equal_to: %w{disc ram}, default: 'disc')

  attribute(:install_method, equal_to: %w{package}, default: 'package')
  attribute(:package_version, kind_of: String)
  attribute(:package_name, kind_of: String, default: 'rabbitmq-server')

  attribute(:user, kind_of: String, default: 'rabbitmq')
  attribute(:group, kind_of: String, default: 'rabbitmq')
  attribute(:environment, kind_of: Hash, default: lazy { default_environment })

  attribute(:config_path, kind_of: String, default: '/etc/rabbitmq/rabbitmq.config')
  attribute(:data_path, kind_of: String, default: '/var/lib/rabbitmq')
  attribute(:log_path, kind_of: String, default: '/var/log/rabbitmq')

  attribute(:erl_empd_address, kind_of: [String, NilClass], default: nil)
  attribute(:node_name, kind_of: [String, NilClass], default: nil)
  attribute(:node_ip_address, kind_of: [String, NilClass], default: nil)
  attribute(:node_port, kind_of: [Integer, NilClass], default: nil)
  attribute(:ssl_verify, equal_to: [true, false], default: false)

  def command
    "rabbitmq-server >#{log_path}/startup_log 2>#{log_path}/startup_err"
  end

  def default_environment
    { 'CONFIG_FILE' => config_path }.tap do |h|
      h.merge('ERL_EPMD_ADDRESS' => erl_empd_address) unless erl_empd_address.nil?
      h.merge('NODE_NAME' => node_name) unless node_name.nil?
      h.merge('NODE_IP_ADDRESS' => node_ip_address) unless node_ip_address.nil?
      h.merge('NODE_PORT' => node_port) unless node_port.nil?
    end
  end

  def ssl?
    ssl_verify
  end

  def master?
    cluster_role_type == 'master'
  end

  def slave?
    cluster_role_type == 'slave'
  end
end

class Chef::Provider::RabbitmqService < Chef::Provider
  include Poise
  provides(:rabbitmq_service)
  include PoiseService::ServiceMixin
  include RabbitmqClusterCookbook::Helpers

  def load_current_resource
    cluster_name = rabbitmqctl_eval("'binary_to_list(rabbit_nodes:cluster_name()).'").gsub(/"/, '')
    node_type = rabbitmqctl_eval("'rabbit_mnesia:node_type().'")

    @current_resource = Chef::Resource::RabbitmqService.new(new_resource.name)
    @current_resource.cluster_name(cluster_name) unless cluster_name.empty?
    @current_resource.cluster_role_type(new_resource.cluster_role_type)
    @current_resource.cluster_node_type(node_type) unless node_type.empty?

    @current_resource
  rescue Mixlib::ShellOut::ShellCommandFailed
    @current_resource = nil
  ensure
    if @current_resource
      Chef::Log.debug("#{@current_resource.name} cluster_name - #{@current_resource.cluster_name}")
      Chef::Log.debug("#{@current_resource.name} cluster_role_type - #{@current_resource.cluster_role_type}")
      Chef::Log.debug("#{@current_resource.name} cluster_node_type - #{@current_resource.cluster_node_type}")
    end
  end

  def rabbitmqctl_eval(*args)
    run_command('rabbitmqctl eval', *args)
  end

  def action_enable
    notifying_block do
      include_recipe 'erlang::default'
      include_recipe 'chef-vault::default'

      directory new_resource.data_path do
        recursive true
        owner new_resource.user
        group new_resource.group
        mode '0755'
      end

      item = chef_vault_item(node['rabbitmq-cluster']['bag_name'], node['rabbitmq-cluster']['bag_item'])
      file ::File.join(new_resource.data_path, '.erlang.cookie') do
        content item['cookie']
        mode '0640'
        owner new_resource.user
        group new_resource.group
        only_if { item['cookie'] }
      end

      file '/usr/sbin/policy-rc.d' do
        content 'exit 101'
        mode '0744'
        only_if { node['platform_family'] == 'debian' }
      end

      if new_resource.ssl?
        directory [new_resource.tls_cert_file, new_resource.tls_ca_file, new_resource.tls_key_file] do
          recursive true
          mode '0644'
        end

        file new_resource.tls_cert_file do
          content item['certificate']
          owner new_resource.user
          group new_resource.group
          mode '0644'
          only_if { item['certificate'] }
        end

        file new_resource.tls_ca_file do
          content item['ca_certificate']
          owner new_resource.user
          group new_resource.group
          mode '0644'
          only_if { item['ca_certificate'] }
        end

        file new_resource.tls_key_file do
          sensitive true
          content item['private_key']
          owner new_resource.user
          group new_resource.group
          mode '0640'
          only_if { item['private_key'] }
        end
      end

      package new_resource.package_name do
        version new_resource.package_version unless new_resource.package_version.nil?
        action :upgrade
        only_if { new_resource.install_method == 'package' }
      end
    end
    super
  end

  def action_start
    super
    notifying_block do
      execute "rabbitmqctl set_cluster_name #{new_resource.cluster_name}" do
        environment new_resource.environment
        guard_interpreter :default
        not_if is_clustered?
        not_if { @current_resource && @current_resource.cluster_name == new_resource.cluster_name }
      end

      execute "rabbitmqctl set_cluster_node_type #{new_resource.cluster_node_type}" do
        environment new_resource.environment
        guard_interpreter :default
        not_if is_clustered?
      end

      execute "rabbitmqctl change_cluster_node_type #{new_resource.cluster_node_type}" do
        environment new_resource.environment
        guard_interpreter :default
        only_if is_clustered?
        not_if { @current_resource && @current_resource.cluster_node_type == new_resource.cluster_node_type }
      end

      execute "rabbitmqctl join_cluster #{new_resource.cluster_name}" do
        environment new_resource.environment
        guard_interpreter :default
        not_if is_clustered?
        not_if { new_resource.master? }
      end

      execute 'rabbitmqctl start_app' do
        environment 'HOME' => '/root'
        guard_interpreter :default
      end
    end
  end

  def action_stop
    notifying_block do
      execute 'rabbitmqctl stop_app' do
        environment 'HOME' => '/root'
        guard_interpreter :default
      end
    end
    super
  end

  def action_disable
    notifying_block do
      execute 'rabbitmqctl reset' do
        environment 'HOME' => '/root'
        guard_interpreter :default
      end

      file new_resource.cookie_path do
        action :delete
      end

      service 'epmd' do
        action :stop
      end
    end
    super
  end

  # @api private
  def service_options(service)
    service.command(new_resource.command)
    service.directory(new_resource.data_path)
    service.user(new_resource.user)
    service.restart_on_update(true)
  end

  # @api private
  # @return [TrueClass, FalseClass]
  def is_clustered?
    return false unless @current_resource
    rabbitmqctl_eval("'rabbit_mnesia:is_clustered().'") == 'true'
  end
end
