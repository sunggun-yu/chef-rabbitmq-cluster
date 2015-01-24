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
    <td>Master node name to join in cluster. default value is an example. please modify in your recipe.</td>
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

### rabbitmq-cluster::default

Include `rabbitmq-cluster` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[rabbitmq-cluster::default]"
  ]
}
```

## License and Authors

Author:: Sunggun Yu (<YOUR_EMAIL>)
