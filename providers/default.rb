#
# Cookbook Name:: rabbitmq-cluster
# Recipe:: default
#
# Copyright (C) 2015 Sunggun Yu
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

include Chef::Mixin::ShellOut

use_inline_resources

# Checking node was joined in cluster
def joined_cluster?(cluster_name)
  # Remove first line (Cluster status of node rabbit@rabbit2 ...) -> trim all line feed -> trim all the white space -> grep running_nodes with regex -> grep master node name
  # rabbitmqctl cluster_status | sed "1d" | tr "\n" " " | tr -d " " | grep -o -e "{running_nodes.*]}," | grep ${master_node_name}
  cmd = "rabbitmqctl cluster_status | sed \"1d\" | tr \"\n\" \" \" | tr -d \" \" | grep -o -e \"{running_nodes.*]},\" | grep \"#{cluster_name}\""
  cmd = Mixlib::ShellOut.new(cmd)
  cmd.environment['HOME'] = ENV.fetch('HOME', '/root')
  cmd.run_command
  begin
    cmd.error!
    true
  rescue
    false
  end
end

# Checking whether node is slave or not
def slave_node?(node_type)
  if node_type == 'slave'
    true
  elsif node_type == 'master'
    false
  else
    Chef::Application.fatal!('Only "slave" or "master" is possible to be applied for node type')
  end
end

# Action for joining cluster
action :join do
  Chef::Application.fatal!('rabbitmq_cluster with action :join requires a non-nil/empty note_type.') if new_resource.node_type.nil? || new_resource.node_type.empty?
  Chef::Application.fatal!('rabbitmq_cluster with action :join requires a non-nil/empty cluster_name.') if new_resource.cluster_name.nil? || new_resource.cluster_name.empty?
  # The master node will be skipped joining cluster
  if slave_node?(new_resource.node_type)
    unless joined_cluster?(new_resource.cluster_name)
      cmd = "rabbitmqctl stop_app && rabbitmqctl join_cluster --ram #{new_resource.cluster_name} && rabbitmqctl start_app"
      # Join cluster as a ram node
      execute cmd do
        sensitive true
      end
    end
  end
end

# Action for changing cluster node type
action :change_cluster_node_type do
  Chef::Application.fatal!('rabbitmq_cluster with action :join requires a non-nil/empty cluster_node_type.') if new_resource.cluster_node_type.nil? || new_resource.cluster_node_type.empty?
  Chef::Application.fatal!('rabbitmq_cluster with action :join requires a non-nil/empty cluster_name.') if new_resource.cluster_name.nil? || new_resource.cluster_name.empty?
  Chef::Application.fatal!('rabbitmq_cluster with action :join requires a non-nil/empty cluster_node_type.') if new_resource.cluster_node_type.nil? || new_resource.cluster_node_type.empty?
  # Once cluster has created, master node also can change the cluster node type.
  # However, current version will skip changing cluster node type for master node.
  if slave_node?(new_resource.node_type) && joined_cluster?(new_resource.cluster_name)
    cmd = "rabbitmqctl stop_app && rabbitmqctl change_cluster_node_type #{new_resource.cluster_node_type} && rabbitmqctl start_app"
    # Change cluster type
    execute cmd do
      sensitive true
    end
  end
end