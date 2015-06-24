#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#

module RabbitmqClusterCookbook
  module Helpers
    def run_command(*args)
      command = Mixlib::ShellOut.new(*args.flatten, env: new_resource.environment)
      command.run_command
      command.error!
      command.stdout.strip
    end
  end
end
