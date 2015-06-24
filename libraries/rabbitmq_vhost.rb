#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise'

class Chef::Resource::RabbitmqVhost < Chef::Resource
  include Poise(fused: true)
  provides(:rabbitmq_vhost)

  attribute(:vhost, kind_of: String, name_attribute: true)
  attribute(:environment, kind_of: Hash, default: {
    'PATH' => '/usr/lib/rabbitmq/bin:/usr/sbin:/usr/bin',
    'HOME' => '/var/lib/rabbitmq'
  })

  def exists?
    "rabbitmqctl -q list vhosts|egrep '^#{vhost}$'"
  end

  action(:create) do
    notifying_block do
      execute "rabbitmqctl add_vhost #{new_resource.vhost}" do
        environment new_resource.environment
        guard_interpreter :default
        not_if new_resource.exists?
      end
    end
  end

  action(:delete) do
    notifying_block do
      execute "rabbitmqctl delete_vhost #{new_resource.vhost}" do
        environment new_resource.environment
        guard_interpreter :default
        only_if new_resource.exists?
      end
    end
  end
end
