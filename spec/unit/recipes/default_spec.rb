#
# Cookbook Name:: rabbitmq-cluster
# Recipe:: default
#
# Copyright (C) 2015 Sunggun Yu
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
require 'spec_helper'

describe_recipe 'rabbitmq-cluster::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(node_attributes).converge(described_recipe) }

  it { expect(chef_run).to join_rabbitmq_cluster('rabbit@rabbit1') }
  it { expect(chef_run).to change_cluster_node_type_rabbitmq_cluster('rabbit@rabbit1') }
end
