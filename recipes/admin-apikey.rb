#
# Cookbook Name:: co-cloudstack
# Recipe:: admin-apikey
#
# Copyright 2014, Cloudops.com
#
# All rights reserved - Do Not Redistribute
#
# Insert API key and secret key to user admin

# Generate admin account API keys using API call.
if node["cloudstack"]["admin"]["api_key"].empty?
  #chef of other cloudstack server exist and have API keys, if do , get a copy of them
  other_nodes = search(:node, "chef_environment:#{node.chef_environment} AND api_key:* NOT name:#{node.name}")
  if ! other_nodes.empty?
    node.normal["cloudstack"]["admin"]["api_key"] = other_nodes.first["cloudstack"]["admin"]["api_key"]
    node.normal["cloudstack"]["admin"]["secret_key"] = other_nodes.first["cloudstack"]["admin"]["secret_key"]
    node.save
  end
  
  cs_ready = port_open("localhost", "8080")

  ruby_block "generate admin keys" do
    block do
      require 'uri'
      require 'net/http'
      require 'json'
      
      url = "http://localhost:8080/client/api/"
      username = "admin"
      password = "password"
      
      login_params = { :command => "login", :username => username, :password => password, :response => "json" }    
      # create sessionkey and cookie of the api session initiated with username and password
      uri = URI(url)
      uri.query = URI.encode_www_form(login_params)
      res = Net::HTTP.get_response(uri)
      get_keys_params = {
          :sessionkey => JSON.parse(res.body)['loginresponse']['sessionkey'], 
          :command => "registerUserKeys", 
          :response => "json", 
          :id => "2"
      }
      
      # use sessionkey + cookie to generate admin API and SECRET keys.
      uri2 = URI(url)
      uri2.query = URI.encode_www_form(get_keys_params) 
      
      get_key = Net::HTTP::Get.new(uri2.to_s)
      get_key['Cookie'] = res.response['set-cookie'].split('; ')[0]
      
      keys = Net::HTTP.start(uri2.hostname, uri2.port) {|http|
        http.request(get_key)
      }
      
      node.normal["cloudstack"]["admin"]["api_key"] = JSON.parse(keys.body)["registeruserkeysresponse"]["userkeys"]["apikey"]
      node.normal["cloudstack"]["admin"]["secret_key"] = JSON.parse(keys.body)["registeruserkeysresponse"]["userkeys"]["secretkey"]
      node.save
    end
    action :create
    not_if { ! node["cloudstack"]["admin"]["api_key"].empty? or cs_ready == false}
  end # ruby_block end
end # if end

#############