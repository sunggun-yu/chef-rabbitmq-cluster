#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise'

class Chef::Resource::RabbitmqPlugin < Chef::Resource
  include Poise(fused: true)
  provides(:rabbitmq_plugin)

  attribute(:plugin, kind_of: String, name_attribute: true)
  attribute(:environment, kind_of: Hash, default: {
    'PATH' => '/usr/lib/rabbitmq/bin:/usr/sbin:/sbin:/usr/bin:/bin',
    'HOME' => '/var/lib/rabbitmq'
  })

  def enabled?
    "rabbitmq-plugins list -e '#{plugin}'|egrep '\b#{plugin}\b'"
  end

  action(:enable) do
    notifying_block do
      execute "rabbitmq-plugins enable #{new_resource.plugin}" do
        environment new_resource.environment
        guard_interpreter :default
        not_if new_resource.enabled?
      end
    end
  end

  action(:disable) do
    notifying_block do
      execute "rabbitmq-plugins disable #{new_resource.plugin}" do
        environment new_resource.environment
        guard_interpreter :default
        only_if new_resource.enabled?
      end
    end
  end
end
