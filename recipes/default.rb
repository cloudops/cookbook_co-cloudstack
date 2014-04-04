#
# Cookbook Name:: co-cloudstack
# Recipe:: default
#
# Copyright 2014, Cloudops.com
#
# All rights reserved - Do Not Redistribute
#

class Chef::Recipe
  include Cloudstack
end

if platform?(%w{redhat centos})
    # Update yum repos
    template "/etc/yum.repos.d/cloudstack.repo" do
      source "cloudstack.repo.erb"
      owner "root"
      group "root"
      mode "0644"
      action :create
    end
    
    package "cloudstack-management" do
       action :install
       if ! node['cloudstack']['version'].empty?
         version node['cloudstack']['version']
       end
    end
end

# Install MySQL client libraries
include_recipe "mysql::client"

# download vhd-util script
include_recipe "co-cloudstack::vhd-util"

directory node['cloudstack']['secondary']['mgt_path'] do
  owner 'root'
  group 'root'
  action :create
end

directory node['cloudstack']['primary']['mgt_path'] do
  owner 'root'
  group 'root'
  action :create
end

# new required folder for CS 4.3
directory "/opt/cloud" do
  owner 'cloud'
  group 'cloud'
  action :create
end

include_recipe "co-cloudstack::init-db"

# Define with role if this node is the NFSserver for Secondary Storage
#include_recipe "co-cloudstack::secondary-local-nfs"
#include_recipe "co-cloudstack::sys-tmpl"

# 
bash "cloudstack-setup-management" do
  code "/usr/bin/cloudstack-setup-management"
  not_if { ::File.exists?("/etc/cloudstack/management/tomcat6.conf") }
end

# directory "/var/log/cloudstack-management" do
#   action :delete
# end

service "cloudstack-management" do
  supports :restart => true, :status => true, :start => true, :stop => true
  action [ :enable, :start ]
end


include_recipe "co-cloudstack::usage"

