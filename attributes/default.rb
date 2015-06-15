#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
default['rabbitmq-cluster']['service_name'] = 'rabbitmq-server'
default['rabbitmq-cluster']['service_user'] = 'rabbitmq'
default['rabbitmq-cluster']['service_group'] = 'rabbitmq'

default['rabbitmq-cluster']['bag_name'] = 'secrets'
default['rabbitmq-cluster']['bag_item'] = 'rabbitmq'

default['rabbitmq-cluster']['service']['package_name'] = 'rabbitmq-server'
default['rabbitmq-cluster']['service']['package_version'] = '3.5.2-1'

default['rabbitmq-cluster']['config']['path'] = '/etc/rabbitmq/rabbitmq.config'
default['rabbitmq-cluster']['config']['default_username'] = 'guest'
default['rabbitmq-cluster']['config']['default_password'] = 'guest'
