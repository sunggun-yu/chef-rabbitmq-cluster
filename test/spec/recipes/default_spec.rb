require 'spec_helper'

describe_recipe 'rabbitmq-cluster::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new do |node, server|
      server.create_data_bag('secrets', {
        'rabbitmq' => {
          'cookie' => 'chocolate'
        }
      })
    end.converge(described_recipe)
  end

  context 'with default attributes' do
    it { expect(chef_run).to create_poise_service_user('rabbitmq').with(group: 'rabbitmq') }
    it { expect(chef_run).to create_rabbitmq_config('rabbitmq-server').with(path: '/etc/rabbitmq/rabbitmq.config') }
    it { expect(chef_run).to enable_rabbitmq_service('rabbitmq-server') }
    it { expect(chef_run).to start_rabbitmq_service('rabbitmq-server') }

    it 'converges successfully' do
      chef_run
    end
  end
end
