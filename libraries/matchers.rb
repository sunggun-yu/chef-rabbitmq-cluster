#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu
# Copyright (C) 2015 Bloomberg Finance L.P.
#

if defined?(ChefSpec)
  def create_rabbitmq_cluster(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:rabbitmq_cluster, :create, resource_name)
  end

  def delete_rabbitmq_cluster(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:rabbitmq_cluster, :delete, resource_name)
  end

  def update_rabbitmq_cluster(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:rabbitmq_cluster, :update, resource_name)
  end
end
