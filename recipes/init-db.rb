#
# Cookbook Name:: co-cloudstack
# Recipe:: init-db
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
# Create and initialize Database of Cloudstack if it does not exist.

# CONDITION: if db already created are already downloaded, don't do it again

if !node["mysql"]["server_root_password"].nil?
  if !node["mysql"]["server_root_password"].empty?
    node.set["cloudstack"]["db"]["rootpassword"] = node["mysql"]["server_root_password"]
    node.save
  end
end

db_init = search(:node, "chef_environment:#{node.chef_environment} AND tags:db_init").count
if db_init == 0

  bash "init cloudstack database" do
    code <<-EOF
      /usr/bin/cloudstack-setup-databases #{node["cloudstack"]["db"]["user"]}:#{node["cloudstack"]["db"]["password"]}@#{node["cloudstack"]["db"]["host"]} \
      --deploy-as=#{node["cloudstack"]["db"]["rootusername"]}:#{node["cloudstack"]["db"]["rootpassword"]} \
      -m #{node["cloudstack"]["db"]["management_server_key"]} \
      -k #{node["cloudstack"]["db"]["database_key"]}
    EOF
    action :run # see actions section below
  end

  # Add tags:init-db to node to remember that the database as been created and initialized.
  ruby_block "db_init" do
    block do
      node.tags << "db_init"
      node.run_list.remove("recipe[co-cloudstack::init-db]")
      node.save
    end
    #action :create
  end
  
end



