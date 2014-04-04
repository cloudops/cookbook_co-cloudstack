#
# Cookbook Name:: co-cloudstack
# Recipe:: secondary-local-nfs
#
# Copyright 2014, Cloudops.com
#
# All rights reserved - Do Not Redistribute


# Update local NFSserver configuration if the NFS server is this node.
if node['cloudstack']['secondary']['host'] == node["ipaddress"]
  include_recipe "co-nfs::exports"
end