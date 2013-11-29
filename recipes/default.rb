#
# Cookbook Name:: co-cloudstack
# Recipe:: default
# Author:: Pierre-Luc Dion (<pdion@cloudops.com>)
#
# Copyright:: Copyright (c) 2013 CloudOps.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# Perform installation of Cloudstack and execute some recipes in the proper order.


# load cookbook Libraries
class Chef::Recipe
  include Cloudstack
end

if platform?(%w{redhat centos fedora})
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
    end
end

# download vhd-util script
include_recipe "co-cloudstack::vhd-util"

directory node['cloudstack']['secondary']['mgt_path'] do
  owner 'root'
  group 'root'
  recursive true
  action :create
end

include_recipe "co-cloudstack::init-db"

bash "cloudstack-setup-management" do
  code "/usr/bin/cloudstack-setup-management"
  not_if { ::File.exists?("/etc/cloudstack/management/tomcat6.conf") }
end

directory "/var/log/cloudstack-management" do
  action :delete
end

service "cloudstack-management" do
  supports :restart => true, :status => true, :start => true, :stop => true
  action [ :enable, :start ]
end



include_recipe "co-cloudstack::sys-tmpl"
include_recipe "co-cloudstack::secondary-local-nfs"

