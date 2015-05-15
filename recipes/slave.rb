#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
return if Chef::Config[:solo]

m = search(:node, "chef_environment:#{node.chef_environment} AND tags:rabbitmq.master").first
node.default['rabbitmq-cluster']['master_node_name'] = "rabbit@#{m['hostname']}"
include_recipe 'rabbitmq-cluster::default'

node.tag('rabbitmq.slave')
