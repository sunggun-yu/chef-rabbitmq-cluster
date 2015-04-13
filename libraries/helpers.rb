#
# Cookbook Name:: rabbitmq-cluster
# Recipe:: default
#
# Copyright (C) 2015 Sunggun Yu
# Copyright (C) 2015 Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module RabbitmqClusterCookbook
  module Helpers
    # Runs `args` on the RabbitMQ CLI.
    def rabbitmqctl(*args)
      command = Mixlib::ShellOut.new("rabbitmqctl #{args.join(' ')}")
      command.environment['HOME'] = ENV.fetch('HOME', '/root')
      command.run_command
      command
    end

    # Evaluates `args` as erlang code against running cluster.
    def rabbitmqctl_eval(*args)
      rabbitmqctl('eval', args)
    end

    # @return [String] Type of the node (disc or ram).
    def rabbitmq_node_type
      command = rabbitmqctl_eval("'rabbit_mnesia:node_type().'")
      command.error!
      command.stdout
    end

    # Use the CLI to determine if this node is part of the cluster
    # that is specified with `cluster_name`.
    # @param node_type [String] Type of the node.
    # @param cluster_name [String] Name of the cluster.
    # @return [TrueClass, FalseClass]
    def joined_cluster?(node_type, cluster_name)
      return false if master?(node_type)
      command = rabbitmqctl_eval(%Q('string:equal(list_to_binary("#{cluster_name}"), rabbit_nodes:cluster_name()).'))
      command.error!
      command.stdout == 'true'
    end

    # @param node_type [String] Type of the node.
    # @return [TrueClass, FalseClass]
    def slave?(node_type)
      node_type == 'slave'
    end

    # @param node_type [String] Type of the node.
    # @return [TrueClass, FalseClass]
    def master?(node_type)
      node_type == 'master'
    end

    def service_name
      node['rabbitmq']['service_name']
    end
  end
end
