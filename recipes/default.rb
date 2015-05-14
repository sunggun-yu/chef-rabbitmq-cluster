#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
node.default['rabbitmq']['cluster'] = true
include_recipe 'rabbitmq::default'

rabbitmq_service = service node['rabbitmq']['service_name'] do
  supports restart: true, status: true
  action :nothing
end

rabbitmq_cluster node['rabbitmq-cluster']['master_node_name'] do
  node_type node['rabbitmq-cluster']['cluster_node_type']
  action [:create, :update]
  notifies :restart, "service[#{rabbitmq_service.name}]", :delayed
end
