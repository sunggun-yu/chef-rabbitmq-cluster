#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise'

class Chef::Resource::RabbitmqConfig < Chef::Resource
  include Poise(fused: true)
  provides(:rabbitmq_config)

  attribute(:path, kind_of: String, name_attribute: true)
  attribute(:user, kind_of: String, default: 'rabbitmq')
  attribute(:group, kind_of: String, default: 'rabbitmq')

  attribute(:default_username, kind_of: String, default: 'guest')
  attribute(:default_password, kind_of: String, default: 'guest')
  attribute(:disk_free_limit, kind_of: [Integer, NilClass], default: nil)
  attribute(:loopback_users, kind_of: [Array, NilClass], default: lazy { [ default_username ] })
  attribute(:heartbeat, kind_of: Integer, default: 580)
  attribute(:max_file_descriptors, kind_of: Integer, default: 1024)
  attribute(:ssl_ca_file, kind_of: String, default: '/etc/rabbitmq/ssl/CA/ca.crt')
  attribute(:ssl_cert_file, kind_of: String, default: '/etc/rabbitmq/ssl/certs/rabbitmq.crt')
  attribute(:ssl_ciphers, kind_of: [Array, NilClass], default: nil)
  attribute(:ssl_key_file, kind_of: String, default: '/etc/rabbitmq/ssl/private/rabbitmq.key')
  attribute(:ssl_fail_if_no_peer_cert, equal_to: [true, false], default: true)
  attribute(:ssl_port, kind_of: [Array, Integer], default: 5671)
  attribute(:ssl_verify, equal_to: [true, false], default: false)
  attribute(:ssl_versions, kind_of: [Array, NilClass], default: nil)
  attribute(:tcp_port, kind_of: Integer, default: 5672)
  attribute(:tcp_listeners, kind_of: [Array, Integer], default: lazy { tcp_port })
  attribute(:vm_memory_high_watermark, kind_of: [Integer, NilClass], default: nil)

  # @param [Object] o
  # @return [String]
  # @see http://stackoverflow.com/questions/14519297/prettyprint-a-ruby-hash-to-erlang-term-format
  def to_erl(o=to_hash)
    case o
    when Hash then '[' + o.map { |(k,v)| "{#{k}, #{to_erl(v)}}" }.join(",\n") + ']'
    when Array then '[' + o.map { |v| to_erl(v) }.join(",")  +']'
    when TrueClass then 'true'
    when FalseClass then 'false'
    when Integer, Symbol then o.to_s
    when String then o
    else
      raise "Don't know how to erlify #{o}"
    end
  end

  # Produces a Hash object which can then be converted into an Erlang
  # binary representation using {#to_erl}.
  # @return [Hash]
  def to_hash
    {
     default_user: default_username,
     default_pass: default_password,
     heartbeat: heartbeat,
     tcp_listeners: [ tcp_port ].flatten,
     ssl_listeners: [ ssl_port ].flatten,
     ssl_options: {
                   cacertfile: ssl_ca_file,
                   certfile: ssl_cert_file,
                   keyfile: ssl_key_file,
                   verify: ssl_verify,
                   fail_if_no_peer_cert: ssl_fail_if_no_peer_cert
                  }
    }.tap do |h|
      p

      h[:ssl] = { versions: ssl_versions } unless ssl_versions.nil?
      h[:ssl_options].merge(versions: ssl_versions) unless ssl_versions.nil?
      h[:ssl_options].merge(ciphers: ssl_versions) unless ssl_versions.nil?
      h.merge(loopback_users: loopback_users) unless loopback_users.nil?
      h.merge(disk_free_limit: disk_free_limit) unless disk_free_limit.nil?
      h.merge(vm_memory_high_watermark: vm_memory_high_watermark) unless vm_memory_high_watermark.nil?
    end
  end

  action(:create) do
    notifying_block do
      directory ::File.dirname(new_resource.path) do
        recursive true
      end

      file new_resource.path do
        content new_resource.to_erl
        mode '0640'
        owner new_resource.user
        group new_resource.group
      end
    end
  end

  action(:delete) do
    file new_resource.path do
      action :delete
    end
  end
end
