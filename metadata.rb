name             'rabbitmq-cluster'
maintainer       'Sunggun Yu'
maintainer_email 'sunggun.dev@gmail.com'
license          'Apache 2.0'
description      'Configures rabbitmq cluster'
long_description 'This cookbook configures rabbitmq cluster by executing rabbitmqctl command.'
version          '0.3.0'

depends 'rabbitmq'

supports 'debian'
supports 'ubuntu'
supports 'centos'
