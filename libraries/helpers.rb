#
# Cookbook: rabbitmq-cluster
# License: Apache 2.0
#
# Copyright (C) 2015 Sunggun Yu <sunggun.dev@gmail.com>
# Copyright (C) 2015 Bloomberg Finance L.P.
#

module RabbitmqClusterCookbook
  module Helpers
    def rabbitmqctl(*args)
      command = Mixlib::ShellOut.new("rabbitmqctl #{args.join(' ')}")
      command.environment['HOME'] = ENV.fetch('HOME', '/root')
      command.run_command
      command.stdout.strip
    end

    def rabbitmqctl_eval(*args)
      rabbitmqctl('eval', args)
    end
  end
end
