#
# Cookbook Name:: co-cloudstack
# Recipe:: sys-tmpl
#
# Copyright 2014, Cloudops.com
#
# All rights reserved - Do Not Redistribute
#


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

  ruby_block "template_uploaded" do
    block do
      node.tags << "template_uploaded"
      node.save
    end
    #action :create
  end
  
end
