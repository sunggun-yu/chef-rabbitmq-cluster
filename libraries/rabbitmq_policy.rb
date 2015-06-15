#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'json'
require 'poise'
require 'shellwords'

class Chef::Resource::RabbitmqPolicy < Chef::Resource
  include Poise(fused: true)
  provides(:rabbitmq_policy)

  attribute(:policy, kind_of: String, name_attribute: true)
  attribute(:pattern, kind_of: String)
  attribute(:params, kind_of: Hash)
  attribute(:priority, kind_of: Integer)
  attribute(:vhost, kind_of: String)
  attribute(:apply_to, equal_to: %w{all queues exchanges})
    attribute(:environment, kind_of: Hash, default: {
    'PATH' => '/usr/lib/rabbitmq/bin:/usr/sbin:/usr/bin',
    'HOME' => '/root'
  })

  action(:create) do
    command = ['rabbitmqctl set_policy'].tap do |c|
      c << ['-p', Shellwords.escape(new_resource.vhost)] if new_resource.vhost
      c << ['--priority', new_resource.priority] if new_resource.priority
      c << ['--apply-to', new_resource.apply_to] if new_resource.apply_to
      c << Shellwords.escape(new_resource.policy)
      c << Shellwords.escape(new_resource.pattern)
      c << JSON.dump(new_resource.params)
    end.join(' ')

    notifying_block do
      execute command do
        environment new_resource.environment
        guard_interpreter :default
      end
    end
  end

  action(:delete) do
    command = ['rabbitmqctl clear_policy'].tap do |c|
      c << ['-p', Shellwords.escape(new_resource.vhost)] if new_resource.vhost
      c << Shellwords.escape(new_resource.policy)
    end.join(' ')

    notifying_block do
      execute command do
        environment new_resource.environment
        guard_interpreter :default
      end
    end
  end
end
