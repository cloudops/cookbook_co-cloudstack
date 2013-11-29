#
# Cookbook Name:: co-cloudstack
# Recipe:: admin-apikey
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
# Generate admin account api_key and secret_key by openning integration.api.port
# and store them in attributes of the node.

include_recipe "database::mysql"

mysql_connection_info = {
  :host     => node["cloudstack"]["db"]["host"],
  :username => node["cloudstack"]["db"]["user"],
  :password => node["cloudstack"]["db"]["password"]
}

# check if database cloud is created and populated.
for i in 0..1
  clouddb_exist = `/usr/bin/mysql -u #{mysql_connection_info[:username]} -p#{mysql_connection_info[:password]} -h #{mysql_connection_info[:host]} -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'cloud';" -B`
  if clouddb_exist.empty?   #if empty then db does not exist.
    Chef::Log.warn("cloudstack - cloud database not created yet, sleep 60sec...")
    sleep 60
  else 
    break
  end
end

# check if admin account keys already exist
if node["cloudstack"]["admin"]["api_key"].empty? 

  #chef of other cloudstack server exist and have API keys, if do , get a copy of them
  other_nodes = search(:node, "chef_environment:#{node.chef_environment} AND api_key:* NOT name:#{node.name}")
  if ! other_nodes.empty?
    node.normal["cloudstack"]["admin"]["api_key"] = other_nodes.first["cloudstack"]["admin"]["api_key"]
    node.normal["cloudstack"]["admin"]["secret_key"] = other_nodes.first["cloudstack"]["admin"]["secret_key"]
    node.save
  else

    # Enable API port in order to send API call to generate admin account apikey and secretkey.
    # 1. Enable API port (default['cloudstack']['integration.api.port'])
    # 2. Restart service cloudstack-management
    api_port_open = port_open("localhost", node["cloudstack"]["integration.api.port"])
    #Chef::Provider::Database::Mysql "enable integration api port" do
    mysql_database "enable integration api port" do
      connection mysql_connection_info
      database_name "cloud"
      sql        "UPDATE cloud.configuration SET value = '#{node["cloudstack"]["integration.api.port"]}' WHERE name='integration.api.port'"
      action     :query
      not_if { api_port_open == true }
      notifies :restart, resources(:service => "cloudstack-management"), :immediately
      sleep 70 # wait so Cloudstack-management fully restart.
    end
  
  end




  #api_port_open = port_open("localhost", node["cloudstack"]["integration.api.port"])
  if port_open("localhost", node["cloudstack"]["integration.api.port"])
    # generate new KEYS using the unprotected API port.
    if node["cloudstack"]["admin"]["api_key"].empty? 
      ruby_block "generate admin keys" do
        block do
          url = "http://localhost:#{node['cloudstack']['integration.api.port']}/api?command=registerUserKeys&response=json&id=2"
          begin
            resp = Net::HTTP.get_response(URI.parse(url)) 
          rescue
            Chef::Log.fatal("Can't connect to the API port on localhost:#{node["cloudstack"]["integration.api.port"]}")
            raise "Can't connect to the API port on localhost:#{node["cloudstack"]["integration.api.port"]}"
            return
          end        
          data = JSON.parse(resp.body)
          node.normal["cloudstack"]["admin"]["api_key"] = data["registeruserkeysresponse"]["userkeys"]["apikey"]
          node.normal["cloudstack"]["admin"]["secret_key"] = data["registeruserkeysresponse"]["userkeys"]["secretkey"]
          node.save
        end
      end
    end
  else 
    Chef::Log.warn("cloudstack::admin-apikey - API port:#{node['cloudstack']['integration.api.port']} not open")
    Chef::Log.warn("cloudstack::admin-apikey - Could not generate admin API keys")
  end
end

#ruby_block "apikey" do
#  block do
#    node.run_list.remove("recipe[cloudstack::admin-apikey]")
#  end
#end
