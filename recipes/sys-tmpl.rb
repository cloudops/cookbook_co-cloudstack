#
# Cookbook Name:: co-cloudstack
# Recipe:: sys-tmpl
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
# Download system template into Secondary Storage.

# CONDITION: if template are already downloaded, don't do it again
template = search(:node, "chef_environment:#{node.chef_environment} AND tags:template_uploaded").count
if template == 0


  # mount NFS share on MGT server if not served from local disk
  mount node["cloudstack"]['secondary']['mgt_path'] do
    device "#{node["cloudstack"]['secondary']['host']}:#{node["cloudstack"]['secondary']['path']}"
    fstype "nfs"
    options "rw"
    action [:mount]
    not_if {  node["cloudstack"]['secondary']['host'] == node.name or node["cloudstack"]['secondary']['host'] == node["ipaddress"] }
  end


  # Download system template VM, only if the folder tmpl does not exist.
  # node['cloudstack']['hypervisor_tpl']  is an ARRAY !
  node['cloudstack']['hypervisor_tpl'].each do |hv, url|
    bash "tpl_sys_vm" do
      action :run # see actions section below
      code <<-EOF
        #{node['cloudstack']['cloud-install-sys-tmplt']} \
          -m #{node["cloudstack"]['secondary']['mgt_path']} \
          -u #{url} \
          -h #{hv} -F
      EOF
      returns 0
      timeout 600
      #not_if { ::Dir.exists?("#{node["cloudstack"]['secondary']['mgt_path']}/template/tmpl/1/1") }
    end
  end

  # Update node tags to know templates as been updated.
  ruby_block "template_uploaded" do
    block do
      node.tags << "template_uploaded"
      node.save
    end
    #action :create
  end
  
end
