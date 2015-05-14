# rabbitmq-cluster Cookbook
Installs and configures a RabbitMQ cluster.

This cookbook builds upon the [rabbitmq cookbook][1] which is used
within the Chef Server itself. It properly sets the attributes needed
to build a RabbitMQ cluster using the `rabbitmqctl` commands.

## Supported Platforms
- Ubuntu 12.04, 14.04
- CentOS (RHEL) 5.11, 6.6

## Attributes
## Usage
## Resources/Providers


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


[1]: https://github.com/opscode-cookbooks/rabbitmq
