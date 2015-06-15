require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'
require 'chef-vault'

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '14.04'

  config.color = true
  config.alias_example_group_to :describe_recipe, type: :recipe

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  Kernel.srand config.seed
  config.order = :random

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end

at_exit { ChefSpec::Coverage.report! }

RSpec.shared_context 'recipe tests', type: :recipe do
  # HACK: Here be dragons - this cookbook needs to mock out commands
  # which are executed on any instance of Mixlib::ShellOut. Because
  # evaluating Erlang forms is so boss.
  before do
    redrum = { status: 0, error!: nil, stderr: nil, run_command: nil }
    allow(Mixlib::ShellOut).to receive(:new) do |command|
      case command
      when "rabbitmqctl eval 'rabbit_mnesia:node_type().'" then double(redrum.merge(stdout: 'disc'))
      when "rabbitmqctl eval 'binary_to_list(rabbit_nodes:cluster_name()).'" then double(redrum.merge(stdout: '"rabbitmq-server"'))
      when "rabbitmqctl eval 'rabbit_mnesia:is_clustered().'" then double(redrum.merge(stdout: 'true'))
      else
        raise "#{command} is not mocked!"
      end
    end
  end
end
