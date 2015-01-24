# 0.1.0

Initial release of rabbitmq-cluster

# 0.1.1

Adding default attributes for rabbitmq cookbook.
`['rabbitmq']['cluster'] = true` and `['rabbitmq']['erlang_cookie']` is required for configuring rabbitmq cluster. Also, all the cluster should have same erlang_cookie.
- `default['rabbitmq']['cluster']` = true
- `default['rabbitmq']['erlang_cookie']` = 'AnyAlphaNumericStringWillDo'

Updating tested Vagrant box image list.
- ubuntu/trusty64
- ubuntu/precise64
- chef/centos-6.5
- chef/debian-7.7