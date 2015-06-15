#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#

node.default['rabbitmq-cluster']['service']['cluster_role_type'] = 'master'
include_recipe 'rabbitmq-cluster::default'
