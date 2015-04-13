require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  Kernel.srand config.seed
  config.order = :random

  config.color = true
  config.alias_example_group_to :describe_recipe, type: :recipe
  config.alias_example_group_to :describe_resource, type: :resource

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

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

RSpec.shared_context 'recipe tests', type: :recipe do
  def node_attributes(attributes={})
    attributes.merge(platform: 'ubuntu', version: '12.04')
  end
end
