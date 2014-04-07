# Cookbook Name:: co-cloudstack
# Recipe:: mysql-conf
#
# Copyright 2014, Cloudops.com
#
# All rights reserved - Do Not Redistribute
#
# Specific configurations of MySQL required by CloudStack.

template '/etc/mysql/conf.d/cloudstack.cnf' do
  owner 'mysql'
  owner 'mysql'      
  source 'cloudstack.cnf.erb'
  notifies :restart, 'mysql_service[default]'
end
