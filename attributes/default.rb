#
# Cookbook Name:: co-cloudstack
# Attributes:: default
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

# Default Apache repo for Cloudstack, must point to a valid YUM package repo.
default['cloudstack']['repo'] = "http://cloudstack.apt-get.eu/rhel/4.2/"

default['cloudstack']['cloudstack_url'] = "http://#{node.name}:8080/client"
default['cloudstack']['db']['host'] = node['ipaddress']
default['cloudstack']['db']['user'] = "cloud"
default['cloudstack']['db']['password'] = "password"
default['cloudstack']['db']['rootusername'] = "root"
default['cloudstack']['db']['rootpassword'] = "password"
default['cloudstack']['db']['management_server_key'] = "password"
default['cloudstack']['db']['database_key'] = "password"
         
default['cloudstack']['secondary']['host'] = node["ipaddress"]
default['cloudstack']['secondary']['path'] = "/data/secondary"
default['cloudstack']['secondary']['mgt_path'] = node['cloudstack']['secondary']['path']
         
default['cloudstack']['network']['system']['subnet'] = "172.16.22.0/24"

# FOLLOWING ATTRIBUTES SHOULD NOT REQUIRE MODIFICATION 
default['cloudstack']['vhd-util_url'] = "http://download.cloud.com.s3.amazonaws.com/tools/vhd-util"
default['cloudstack']['vhd-util_path'] = "/usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver"
default['cloudstack']['integration.api.port'] = 8096
default['cloudstack']['cloud-install-sys-tmplt'] = "/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt"
default['cloudstack']['hypervisor_tpl'] = {
  "xenserver" => "http://download.cloud.com/templates/acton/acton-systemvm-02062012.vhd.bz2", 
  "vmware" => "http://download.cloud.com/templates/burbank/burbank-systemvm-08012012.ova",
  "kvm" => "http://download.cloud.com/templates/acton/acton-systemvm-02062012.qcow2.bz2"
}

default['cloudstack']['admin']['api_key'] = "" # automatically generated once Cloudstack installed
default['cloudstack']['admin']['secret_key'] = ""  # automatically generated once Cloudstack installed
default["nfs"]["exports"] = [
  "#{node['cloudstack']['secondary']['path']} #{node['cloudstack']['network']['system']['subnet']}(rw,async,no_root_squash)"
]