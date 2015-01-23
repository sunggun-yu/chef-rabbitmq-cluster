
## rabbitmq-cluster default attributes

# Node type : master | slave
default['rabbitmq-cluster']['node_type'] = 'master'

# Master node name : ex) rabbit@rabbit1
default['rabbitmq-cluster']['master_node_name'] = 'rabbit@rabbit1'

# Cluster node type : disc | ram
default['rabbitmq-cluster']['cluster_node_type'] = 'disc'
