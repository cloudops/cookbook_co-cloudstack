#
# Cookbook Name:: co-cloudstack
# Recipe:: init-db
#
# Copyright 2014, Cloudops.com
#
# All rights reserved - Do Not Redistribute
#
# Create and initialize Database of Cloudstack if it does not exist.

# CONDITION: if db already created are already downloaded, don't do it again
# Look for an existing MySQL server in the environment, if found use it as MySQL server for Cloudstack
# Otherwise use localhost
mysql_server_found = search(:node, 'run_list:recipe\[mysql\:\:server\]' "AND chef_environment:#{node.chef_environment} AND NOT name:#{node.name}")
if mysql_server_found.count > 0
    node.normal['cloudstack']['db']['host'] = mysql_server_found.first.ipaddress
    node.save
end

# if using community mysql cookbook:
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

  ruby_block "db_init" do
    block do
      node.tags << "db_init"
      node.run_list.remove("recipe[co-cloudstack::init-db]")
      node.save
    end
    not_if { node.tags.include?("db_init") }
    #action :create
  end

end
  
# If a database already exist in the environment, configure Cloudstack to use it
db_configured = search(:node, "chef_environment:#{node.chef_environment} AND tags:db_init AND node:#{node.name}").count
if db_configured == 0
  
  bash "cloudstack conf database connection" do
    code <<-EOF
      /usr/bin/cloudstack-setup-databases #{node["cloudstack"]["db"]["user"]}:#{node["cloudstack"]["db"]["password"]}@#{node["cloudstack"]["db"]["host"]} \
      -m #{node["cloudstack"]["db"]["management_server_key"]} \
      -k #{node["cloudstack"]["db"]["database_key"]}
    EOF
    action :run # see actions section below
  end
  Chef::Log.info("co-cloudstack: configuring database connection.")
  ruby_block "db_init" do
    block do
      node.tags << "db_init"
      node.run_list.remove("recipe[co-cloudstack::init-db]")
      node.save
    end
    not_if { node.tags.include?("db_init") }
    #action :create
  end

end