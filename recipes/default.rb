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

if node['rabbitmq-cluster']['node_type'] == 'master' && node['rabbitmq-cluster']['cluster_node_type'] == 'ram'
  log "Node is not clustered. cluster_node_type ram will be ignored." do
    level :warn
    # Leave master node as disc node.
  end
end

if node['rabbitmq-cluster']['node_type'] == 'slave'
  log "Join master cluster #{node['rabbitmq-cluster']['master_node_name']}" do
    notifies :run, 'execute[stop_app]', :immediately
    notifies :run, 'execute[join_cluster]', :immediately
    if node['rabbitmq-cluster']['cluster_node_type'] == 'disc'
      notifies :run, 'execute[change_cluster_node_type]', :immediately
    end
    notifies :run, 'execute[start_app]', :immediately
  end
end

execute 'stop_app' do
  command 'rabbitmqctl stop_app'
  action :nothing
end

execute 'join_cluster' do
  command "rabbitmqctl join_cluster --ram #{node['rabbitmq-cluster']['master_node_name']}"
  action :nothing
  returns [0, 2]
end

execute 'change_cluster_node_type' do
  command "rabbitmqctl change_cluster_node_type #{node['rabbitmq-cluster']['cluster_node_type']}"
  action :nothing
end

execute 'start_app' do
  command 'rabbitmqctl start_app'
  action :nothing
end
