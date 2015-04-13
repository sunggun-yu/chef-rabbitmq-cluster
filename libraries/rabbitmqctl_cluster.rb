#
# Cookbook Name:: rabbitmq-cluster
# Recipe:: default
#
# Copyright (C) 2015 Sunggun Yu
# Copyright (C) 2015 Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'forwardable'

class Chef::Resource::RabbitmqCluster < Chef::Resource::LWRPBase
  self.resource_name = :rabbitmq_cluster
  actions :join, :change_cluster_node_type, :set_cluster_name
  default_action :join

  attribute(:cluster_name,
    kind_of: String,
    name_attribute: true,
    required: true,
    cannot_be: :empty)
  attribute(:node_type,
    kind_of: String,
    required: true,
    default: 'master',
    regex: /^(master|slave)$/)
  attribute(:cluster_node_type,
    kind_of: String,
    default: 'disc',
    regex: /^(disc|ram)$/)
end

class Chef::Provider::RabbitmqCluster < Chef::Provider::LWRPBase
  include RabbitmqClusterCookbook::Helpers
  extend Forwardable
  def_delegators :@new_resource, :cluster_name, :node_type, :cluster_node_type

  use_inline_resources if defined?(use_inline_resources)
  provides :rabbitmq_cluster

  action :set_cluster_name do
    if joined_cluster?(node_type, cluster_name)
      rabbitmqctl('stop_app')
      rabbitmqctl('set_cluster_name', cluster_name)
      rabbitmqctl('start_app')
    end
  end

  action :join do
    unless joined_cluster?(node_type, cluster_name)
      rabbitmqctl('stop_app')
      rabbitmqctl('join_cluster', "--#{cluster_node_type}", cluster_name)
      rabbitmqctl('start_app')
    end
  end

  action :change_cluster_node_type do
    if joined_cluster?(node_type, cluster_name)
      unless rabbitmq_node_type == cluster_node_type
        rabbitmqctl('stop_app')
        rabbitmqctl('change_cluster_node_type', cluster_node_type)
        rabbitmqctl('start_app')
      end
    end
  end
end
