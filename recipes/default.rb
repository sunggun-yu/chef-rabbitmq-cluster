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
name = node['rabbitmq']['service_name']
service name do
  supports restart: true, status: true
  action :nothing
end

# Join in cluster : master node will be skipped.
# Change the cluster node type : master node will be skipped. (for now)
rabbitmq_cluster node['rabbitmq-cluster']['master_node_name'] do
  node_type node['rabbitmq-cluster']['node_type']
  cluster_node_type node['rabbitmq-cluster']['cluster_node_type']
  action [:join, :change_cluster_node_type, :set_cluster_name]
  notifies :restart, "service[#{name}]", :delayed
end
