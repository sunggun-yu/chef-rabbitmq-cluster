#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#

if defined?(ChefSpec)
  %i{create delete}.each do |action|
    %w{config user parameter policy vhost}.each do |resource|
      define_method(:"#{action}_rabbitmq_#{resource}") do |resource_name|
        ChefSpec::Matchers::ResourceMatcher.new(:"rabbitmq_#{resource}", action, resource_name)
      end
    end
  end

  %i{enable disable stop start restart reload}.each do |action|
    define_method(:"#{action}_rabbitmq_service") do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new(:rabbitmq_service, action, resource_name)
    end
  end
end
