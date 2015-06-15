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

class Chef::Resource::RabbitmqParameter < Chef::Resource
  include Poise(fused: true)
  provides(:rabbitmq_parameter)

  attribute(:parameter, kind_of: String, name_attribute: true)
  attribute(:component, kind_of: String, required: true)
  attribute(:value, kind_of: String, required: true)
  attribute(:vhost, kind_of: String)
    attribute(:environment, kind_of: Hash, default: {
    'PATH' => '/usr/lib/rabbitmq/bin:/usr/sbin:/usr/bin',
    'HOME' => '/root'
  })

  action(:create) do
    command = ['rabbitmqctl set_parameter'].tap do |c|
      c << ['-p', Shellwords.escape(new_resource.vhost)] if new_resource.vhost
      c << Shellwords.escape(new_resource.component)
      c << Shellwords.escape(new_resource.parameter)
      c << Shellwords.escape(new_resource.value)
    end.join(' ')

    notifying_block do
      execute command do
        environment new_resource.environment
        guard_interpreter :default
      end
    end
  end

  action(:delete) do
    command = ['rabbitmqctl clear_parameter'].tap do |c|
      c << ['-p', Shellwords.escape(new_resource.vhost)] if new_resource.vhost
      c << Shellwords.escape(new_resource.component)
      c << Shellwords.escape(new_resource.parameter)
    end.join(' ')

    notifying_block do
      execute command do
        environment new_resource.environment
        guard_interpreter :default
      end
    end
  end
end
