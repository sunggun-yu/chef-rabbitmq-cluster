require 'spec_helper'

describe service('rabbitmq-server') do
  it { should be_enabled }
  it { should be_running }
end
