#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise'

class Chef::Resource::RabbitmqCluster < Chef::Resource
  include Poise
  provides(:rabbitmq_cluster)
  actions(:create, :update, :delete)

  attribute(:cluster_name, kind_of: String, name_attribute: true)
  attribute(:node_type, kind_of: String, default: 'disc', regex: /^(disc|ram)$/)
end

class Chef::Provider::RabbitmqCluster < Chef::Provider
  include Poise
  include RabbitmqClusterCookbook::Helpers
  provides(:rabbitmq_cluster)

  def load_current_resource
    @current_resource = Chef::Resource::RabbitmqCluster.new(new_resource.name)
    @current_resource.cluster_name(rabbitmqctl_eval("'binary_to_list(rabbit_nodes:cluster_name()).'").gsub(/"/, ''))
    @current_resource.node_type(rabbitmqctl_eval("'rabbit_mnesia:node_type().'"))

    Chef::Log.debug("#{@current_resource.name} load_current_resource")
    Chef::Log.debug("#{@current_resource.name} cluster_name - #{@current_resource.cluster_name}")
    Chef::Log.debug("#{@current_resource.name} node_type - #{@current_resource.node_type}")
    @current_resource
  end

  def action_create
    Chef::Log.debug("#{new_resource.name} cluster_name - #{new_resource.cluster_name}")
    Chef::Log.debug("#{new_resource.name} node_type - #{new_resource.node_type}")

    notifying_block do
      execute 'rabbitmqctl stop_app'
      execute "rabbitmqctl join_cluster #{new_resource.cluster_name}"
      execute "rabbitmqctl change_cluster_node_type #{new_resource.node_type}"
      execute 'rabbitmqctl start_app'
    end unless is_clustered?
  end

  def action_delete
    Chef::Log.debug("#{new_resource.name} cluster_name - #{new_resource.cluster_name}")
    Chef::Log.debug("#{new_resource.name} node_type - #{new_resource.node_type}")

    notifying_block do
      execute 'rabbitmqctl reset'
    end if is_clustered?
  end

  def action_update
    Chef::Log.debug("#{new_resource.name} cluster_name - #{new_resource.cluster_name}")
    Chef::Log.debug("#{new_resource.name} node_type - #{new_resource.node_type}")

    notifying_block do
      execute 'rabbitmqctl stop_app'
      execute "rabbitmqctl change_cluster_node_type #{new_resource.node_type}"
      execute "rabbitmqctl set_cluster_name #{new_resource.cluster_name}"
      execute 'rabbitmqctl start_app'
    end if is_clustered? and update_cluster?
  end

  # @api private
  def is_clustered?
    rabbitmqctl_eval("'rabbit_mnesia:is_clustered().'") == 'true'
  end

  # @api private
  def update_cluster?
    return true unless @current_resource.cluster_name == new_resource.cluster_name
    return true unless @current_resource.node_type == new_resource.node_type
    false
  end
end
