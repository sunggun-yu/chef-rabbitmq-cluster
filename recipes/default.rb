#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
poise_service_user node['rabbitmq-cluster']['service_user'] do
  group node['rabbitmq-cluster']['service_group']
end

config = rabbitmq_config node['rabbitmq-cluster']['service_name'] do |r|
  user node['rabbitmq-cluster']['service_user']
  group node['rabbitmq-cluster']['service_group']

  node['rabbitmq-cluster']['config'].each_pair { |k, v| r.send(k, v) }
  notifies :restart, "rabbitmq_service[#{name}]", :delayed
end

rabbitmq_service node['rabbitmq-cluster']['service_name'] do |r|
  user node['rabbitmq-cluster']['service_user']
  group node['rabbitmq-cluster']['service_group']
  config_path config.path

  node['rabbitmq-cluster']['service'].each_pair { |k, v| r.send(k, v) }
end

node['rabbitmq-cluster']['plugins'].each { |n| rabbitmq_plugin n }
