#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise'
require_relative 'helpers'

class Chef::Resource::RabbitmqUser < Chef::Resource
  include Poise
  provides(:rabbitmq_user)
  actions(:create, :delete)

  attribute(:username, kind_of: String, name_attribute: true)
  attribute(:password, kind_of: String, required: true)
  attribute(:vhost, kind_of: String)
  attribute(:permissions, kind_of: [Array, String], default: [])
  attribute(:tag, kind_of: [Array, String], default: [])
    attribute(:environment, kind_of: Hash, default: {
    'PATH' => '/usr/lib/rabbitmq/bin:/usr/sbin:/usr/bin',
    'HOME' => '/var/lib/rabbitmq'
  })
end

class Chef::Provider::RabbitmqUser < Chef::Provider
  include Poise
  provides(:rabbitmq_user)
  include RabbitmqClusterCookbook::Helpers

  def load_current_resource
    tags = run_command("rabbitmqctl -q list_users|egrep '^#{new_resource.username}\W+'").gsub(%r{\[|\]}, '')
    permissions = run_command("rabbitmqctl -q list_permissions #{new_resource.username}|egrep '^#{new_resource.vhost}\W+'")
    @current_resource = Chef::Resource::RabbitmqUser.new(new_resource.name)
    @current_resource.environment(new_resource.environment)
    @current_resource.password(new_resource.password)
    @current_resource.tag(tags.split.drop(1))
    @current_resource.permissions(permissions.split.drop(1))
  rescue Mixlib::ShellOut::ShellCommandFailed
    @current_resource = nil
  end

  def action_create
    notifying_block do
      execute "rabbitmqctl add_user #{new_resource.username}" do
        sensitive true
        command ['rabbitmqctl add_user', new_resource.username, new_resource.password].join(' ')
        environment new_resource.environment
        guard_interpreter :default
        not_if { @current_resource }
      end

      execute "rabbitmqctl set_permissions -p #{new_resource.vhost} #{new_resource.username}" do
        command ['rabbitmqctl set_permissions', "-p #{new_resource.vhost}", new_resource.username, new_resource.permissions].join(' ')
        environment new_resource.environment
        guard_interpreter :default
        not_if { @current_resource && @current_resource.permissions == new_resource.permissions }
      end

      execute "rabbitmqctl set_user_tags #{new_resource.tags}" do
        environment new_resource.environment
        guard_interpreter :default
        not_if { @current_resource && @current_resource.tag == new_resource.tag }
      end
    end
  end

  def action_delete
    notifying_block do
      execute "rabbitmqctl delete_user #{new_resource.username}" do
        environment new_resource.environment
        guard_interpreter :default
        only_if { @current_resource }
      end
    end
  end
end
