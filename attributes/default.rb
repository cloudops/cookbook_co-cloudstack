#
# Cookbook Name:: co-cloudstack
# Recipe:: default
#
# Copyright 2014, CloudOps.com
#
# All rights reserved - Do Not Redistribute

# Update yum repo

# Apache repo:
# version = version of package to install if not define = latest from the repo
default['cloudstack']['version'] = ""
# relase_major = release version, used for the repo URL
if node['cloudstack']['version'].empty?
    default['cloudstack']['relase_major'] = "4.3"
else
    default['cloudstack']['relase_major'] =  "#{node['cloudstack']['version'].split('.')[0]}.#{node['cloudstack']['version'].split('.')[1]}"
end
default['cloudstack']['repo'] = "http://cloudstack.apt-get.eu/rhel/#{node['cloudstack']['relase_major']}/"
         
default['cloudstack']['cloudstack_url'] = "http://#{node.name}:8080/client"

default['cloudstack']['db']['host'] = "127.0.0.1"
default['cloudstack']['db']['user'] = "cloud"
default['cloudstack']['db']['password'] = "password"
default['cloudstack']['db']['rootusername'] = "root"
default['cloudstack']['db']['rootpassword'] = "password"
default['cloudstack']['db']['management_server_key'] = "password"
default['cloudstack']['db']['database_key'] = "password"

# Default Secondary storage where system template VMs are copied.
default['cloudstack']['secondary']['host'] = node["ipaddress"]
default['cloudstack']['secondary']['path'] = "/data/secondary"
default['cloudstack']['secondary']['mgt_path'] = node['cloudstack']['secondary']['path']
# Used in lab env for shared primary storage.
default['cloudstack']['primary']['host'] = node["ipaddress"]
default['cloudstack']['primary']['path'] = "/data/primary"
default['cloudstack']['primary']['mgt_path'] = node['cloudstack']['primary']['path']

# subnet use to restrict NFS access to the secondary storage served from the Management server
# default['cloudstack']['network']['system']['subnet'] = "172.16.22.0/24"
default['cloudstack']['network']['system']['subnet'] = "*"


# FOLLOWING ATTRIBUTES SHOULD NOT REQUIRE MODIFICATION 
# 
default['cloudstack']['vhd-util_url'] = "http://download.cloud.com.s3.amazonaws.com/tools/vhd-util"
default['cloudstack']['vhd-util_path'] = "/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver"
default['cloudstack']['integration.api.port'] = 8096
default['cloudstack']['cloud-install-sys-tmplt'] = "/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt"

case node['cloudstack']['version']
when "4.3"
    default['cloudstack']['hypervisor_tpl'] = {
        "xenserver" => "http://download.cloud.com/templates/4.3/systemvm64template-2014-01-14-master-xen.vhd.bz2"
    }
else # "4.2.x"
    default['cloudstack']['hypervisor_tpl'] = {
        "xenserver" => "http://d21ifhcun6b1t2.cloudfront.net/templates/4.2/systemvmtemplate-2013-07-12-master-xen.vhd.bz2"
    }
end

#default['cloudstack']['hypervisor_tpl'] = {
#  "xenserver" => "http://d21ifhcun6b1t2.cloudfront.net/templates/4.2/systemvmtemplate-2013-07-12-master-xen.vhd.bz2", 
#  "vmware" => "http://d21ifhcun6b1t2.cloudfront.net/templates/4.2/systemvmtemplate-4.2-vh7.ova",
#  "kvm" => "http://d21ifhcun6b1t2.cloudfront.net/templates/4.2/systemvmtemplate-2013-06-12-master-kvm.qcow2.bz2",
#  "lxc" => "http://d21ifhcun6b1t2.cloudfront.net/templates/acton/acton-systemvm-02062012.qcow2.bz2"
#}

default['cloudstack']['admin']['api_key'] = "" # automatically generated
default['cloudstack']['admin']['secret_key'] = ""  # automatically generated

# NFS export instruction if NFS share are local.
default["nfs"]["exports"] = [
  "#{node['cloudstack']['secondary']['path']} #{node['cloudstack']['network']['system']['subnet']}(rw,async,no_root_squash)", 
  "#{node['cloudstack']['primary']['path']} #{node['cloudstack']['network']['system']['subnet']}(rw,async,no_root_squash)"
]