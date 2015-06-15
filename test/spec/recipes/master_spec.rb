require 'spec_helper'

describe_recipe 'rabbitmq-cluster::master' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new do |node, server|
      server.create_data_bag('secrets', {
        'rabbitmq' => {
          'cookie' => 'chocolate',
        }
      })
    end.converge(described_recipe)
  end

  context 'with default attributes' do
    it { expect(chef_run).to include_recipe('rabbitmq-cluster::default') }

    it 'converges successfully' do
      chef_run
    end
  end
end
