#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu
# Copyright (C) 2015 Bloomberg Finance L.P.
#

class Chef::Resource::RabbitmqCluster < Chef::Resource::LWRPBase
  self.resource_name = :rabbitmq_cluster
  provides :rabbitmq_cluster
  actions(:create, :update, :delete)
  default_action(:create)

  attribute(:cluster_name,
    kind_of: String,
    name_attribute: true,
    required: true,
    cannot_be: :empty)
  attribute(:node_type,
    kind_of: String,
    default: 'disc',
    regex: /^(disc|ram)$/)
end
