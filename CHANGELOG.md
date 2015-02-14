rabbitmq-cluster Cookbook CHANGELOG
===========================

## v0.3.0

FEBRUARY 14, 2015

- Refactoring

- Ignore the cluster joining error that occurs when node has already joined in same cluster.
> In this case, rabbitmqctl returns `{ok,already_member}` message.


## v0.2.0

FEBRUARY 1, 2015

- Refactoring with LWRP
- Enhanced checking logic for [#1]
> If master node has included in the running nodes, it means node is already joined in `master_node_name` cluster. this feature has implemented by running shell script with grep before run join cluster. 

- Some cleaning up of documentation.

## v0.1.2

JANUARY 28, 2015

- [#1] Ignore the error that happen when node is already been joined in clusser.

## v0.1.1

- Adding default attributes for rabbitmq cookbook.
>`['rabbitmq']['cluster'] = true` and `['rabbitmq']['erlang_cookie']` is required for configuring rabbitmq cluster. Also, all the cluster should have same erlang_cookie.
 - `default['rabbitmq']['cluster']` = true
 - `default['rabbitmq']['erlang_cookie']` = 'AnyAlphaNumericStringWillDo'

- Updating tested Vagrant box image list.
 - ubuntu/trusty64
 - ubuntu/precise64
 - chef/centos-6.5
 - chef/debian-7.7

## v0.1.0
- Initial release of rabbitmq-cluster






<!-- Issue Links -->
[#1]: https://github.com/sunggun-yu/chef-rabbitmq-cluster/issues/1 "#1"
