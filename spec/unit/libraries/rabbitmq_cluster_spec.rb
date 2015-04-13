require 'spec_helper'

describe_resource 'rabbitmq-cluster::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(node_attributes.merge(step_into: 'rabbitmq_cluster')).converge(described_recipe)
  end
end
