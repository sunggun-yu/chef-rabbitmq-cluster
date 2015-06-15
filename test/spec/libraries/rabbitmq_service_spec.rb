require 'spec_helper'

describe_recipe 'rabbitmq-cluster::default' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(step_into: %w{rabbitmq_service}) do |node, server|
      server.create_data_bag('secrets', {
        'rabbitmq' => {
          'cookie' => 'chocolate'
        }
      })
    end.converge(described_recipe)
  end

  context 'with default attributes' do
    it { expect(chef_run).to include_recipe('chef-vault::default') }
    it { expect(chef_run).to include_recipe('erlang::default') }
    it { expect(chef_run).to create_directory('/var/lib/rabbitmq/mnesia') }
    it { expect(chef_run).to run_execute('rabbitmqctl set_cluster_name rabbitmq-server') }
    it { expect(chef_run).to run_execute('rabbitmqctl set_cluster_node_type disc') }
    it { expect(chef_run).to run_execute('rabbitmqctl join_cluster rabbitmq-server') }
    it { expect(chef_run).to run_execute('rabbitmqctl start_app') }

    it do
      expect(chef_run).to render_file('/var/db/rabbitmq/.erlang.cookie')
      .with(content: 'chocolate')
      .with(user: 'rabbitmq')
      .with(group: 'rabbitmq')
      .with(mode: '0640')
    end

    it 'converges successfully' do
      chef_run
    end
  end
end
