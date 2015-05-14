require 'spec_helper'

describe_recipe 'rabbitmq-cluster::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(node_attributes).converge(described_recipe) }

  it { expect(chef_run).to create_rabbitmq_cluster('rabbit@rabbit1') }
end
