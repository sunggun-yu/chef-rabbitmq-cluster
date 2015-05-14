#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#

class Chef::Provider::RabbitmqCluster < Chef::Provider::LWRPBase
  include RabbitmqClusterCookbook::Helpers
  provides :rabbitmq_cluster

  def load_current_resource
    @current_resource = Chef::Resource::RabbitmqCluster.new(new_resource.name)
    @current_resource.cluster_name(rabbitmqctl_eval("'binary_to_list(rabbit_nodes:cluster_name()).'").gsub(/"/, ''))
    @current_resource.node_type(rabbitmqctl_eval("'rabbit_mnesia:node_type().'"))
  end

  action :update do
    if is_clustered? and update_cluster?
      rabbitmqctl('stop_app')
      rabbitmqctl('change_cluster_node_type', new_resource.node_type)
      rabbitmqctl('set_cluster_name', new_resource.cluster_name)
      rabbitmqctl('start_app')
      new_resource.updated_by_last_action(true)
    end
  end

  action :create do
    unless is_clustered?
      rabbitmqctl('stop_app')
      rabbitmqctl('join_cluster', new_resource.cluster_name)
      rabbitmqctl('change_cluster_node_type', new_resource.node_type)
      rabbitmqctl('start_app')
      new_resource.updated_by_last_action(true)
    end
  end

  action :delete do
    if is_clustered?
      rabbitmqctl('reset')
      new_resource.updated_by_last_action(true)
    end
  end

  def is_clustered?
    rabbitmqctl_eval("'rabbit_mnesia:is_clustered().'") == 'true'
  end

  def update_cluster?
    return true unless @current_resource.cluster_name == new_resource.cluster_name
    return true unless @current_resource.node_type == new_resource.node_type
    false
  end

  def whyrun_supported?
    true
  end

  use_inline_resources if defined?(use_inline_resources)
end
