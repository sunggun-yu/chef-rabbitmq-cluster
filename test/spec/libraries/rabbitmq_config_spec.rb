require 'spec_helper'

describe_recipe 'rabbitmq-cluster::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.new(step_into: %w{rabbitmq_config}).converge(described_recipe) }

  context 'with default attributes' do
    it do
      expect(chef_run).to render_file('/etc/rabbitmq/rabbitmq.config')
      .with(owner: 'rabbitmq')
      .with(group: 'rabbitmq')
      .with(mode: '0640')
    end

    it 'converges successfully' do
      chef_run
    end
  end
end
