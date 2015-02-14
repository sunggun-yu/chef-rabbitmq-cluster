# rabbitmq-cluster Cookbook

This cookbook is wrapper of Opscode rabbitmq cookbook. It configures rabbitmq cluster by executing rabbitmqctl command.

Please take a look at the Vagrant file and roles directory as an example.

## Supported Platforms
rabbitmq-cluster cookbook has tested on the Vagrant box in below.

- ubuntu/trusty64
- ubuntu/precise64
- chef/centos-6.5
- chef/debian-7.7


## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['rabbitmq']['cluster']</tt></td>
    <td>Boolean</td>
    <td>['rabbitmq']['cluster'] = true and ['rabbitmq']['erlang_cookie'] is required for configuring rabbitmq cluster</td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>['rabbitmq']['erlang_cookie']</tt></td>
    <td>String</td>
    <td>['rabbitmq']['cluster'] = true and ['rabbitmq']['erlang_cookie'] is required for configuring rabbitmq cluster. <br>also, all the cluster should have same erlang_cookie.</td>
    <td><tt>AnyAlphaNumericStringWillDo</tt></td>
  </tr>
  <tr>
    <td><tt>['rabbitmq-cluster']['node_type']</tt></td>
    <td>String</td>
    <td>"master" or "slave"</td>
    <td><tt>master</tt></td>
  </tr>
  <tr>
    <td><tt>['rabbitmq-cluster']['master_node_name']</tt></td>
    <td>String</td>
    <td>Master node name to join in cluster. default value is an example. please modify in your recipe.<br>The name "master_node_name" is not a good naming convention. In actually, it is cluster name.</td>
    <td><tt>rabbit@rabbit1</tt></td>
  </tr>
  <tr>
    <td><tt>['rabbitmq-cluster']['cluster_node_type']</tt></td>
    <td>String</td>
    <td>"disc" or "ram"</td>
    <td><tt>disc</tt></td>
  </tr>
</table>

## Usage

Please take look at the roles files and Vagrant file as an example.

- rabbitmq general role (default attributes for installing rabbitmq) : https://github.com/sunggun-yu/chef-rabbitmq-cluster/blob/master/roles/rabbitmq.json

- rabbitmq master role : https://github.com/sunggun-yu/chef-rabbitmq-cluster/blob/master/roles/rabbitmq_master.json

- rabbitmq slave role : https://github.com/sunggun-yu/chef-rabbitmq-cluster/blob/master/roles/rabbitmq_master.json

- Vagrant file (as a node attributes) : https://github.com/sunggun-yu/chef-rabbitmq-cluster/blob/master/Vagrantfile

### rabbitmq-cluster::default

Include `rabbitmq-cluster` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[rabbitmq-cluster::default]"
  ]
}
```

## Resources/Providers
There are 2 LWRP for RabbitMQ cluster

### Join cluster
Join the slave node into the cluster. It will be skipped if node is master or node is already joined in cluster. 

```
rabbitmq_cluster node['rabbitmq-cluster']['master_node_name'] do
  node_type node['rabbitmq-cluster']['node_type']
  action :join
end
```

- Required resources
 - `:cluster_name` : master node name. also, it is name attribute of LWRP.
 - `:node_type` : `master` or `slave`


### Change cluster node type
Change the cluser node type (`ram` | `disc`). It will be skipped if node is master or not joined in cluster.

```
rabbitmq_cluster node['rabbitmq-cluster']['master_node_name'] do
  node_type node['rabbitmq-cluster']['node_type']
  cluster_node_type node['rabbitmq-cluster']['cluster_node_type']
  action :change_cluster_node_type
end
```

- Required resources
 - `:cluster_name` : master node name. also, it is name attribute of LWRP.
 - `:node_type` : `master` or `slave`
 - `:cluster_node_type` : `disc` or `ram`


## License and Authors

Author:: Sunggun Yu (sunggun.dev@gmail.com)

```text
Copyright (c) 2015, Sunggun Yu

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```