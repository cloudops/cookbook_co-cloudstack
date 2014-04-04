co-cloudstack Cookbook
======================

Install and configure Apache Cloudstack cloud orchestrator. This cookbook currently support only Redhat based distributions of Linux.
This Chef cookbook install Cloudstack based on RPMs and executes folowing steps:

1. Update yum repo
2. Install RPMs
3. Create and initialize database
4. Generate admin account api keys `recipe[co-cloudstack::admin-apikey]`
5. Download system VM template
6. Configure and export NFS Secondary storage if local

Currently tested on CentOs 6.x x86_64.


Originaly this cookbook as not been developped to work with the [community mysql cookbook](http://community.opscode.com/cookbooks/mysql). Warning: this cookbook provide passwords in clear text as attributes.


About Apache Cloudstack
=======================

More info on: http://cloudstack.apache.org/

Requirements
------------

The following cookbooks are direct dependencies:

- <tt>'co-nfs'</tt> - To configure and export Secondary Storage.


Attributes
----------

Attributes can be customized for securty reason. The cookbook does not support encrypted data bag usage for now.

- <tt>node['cloudstack']['repo']</tt> - yum repo url to use, default: http://cloudstack.apt-get.eu/rhel/4.2/
- <tt>node['cloudstack']['db']['host']</tt> - cloud mysql host/ip, default = <tt>node['ipaddress']</tt>
- <tt>node['cloudstack']['db']['user']</tt> - cloud databases mysql user
- <tt>node['cloudstack']['db']['password']</tt> - cloud databases mysql password
- <tt>node['cloudstack']['db']['rootusername']</tt> - root mysql user
- <tt>node['cloudstack']['db']['rootpassword']</tt> - root mysql password
- <tt>node['cloudstack']['network']['system']['subnet']</tt> - Management network subnet (use for the nfs export) 
- <tt>node['cloudstack']['secondary']['path']</tt> - Local path for the Secondary Storage. default = <tt>/data/secondary</tt>


Usage
-----

##### Create an environment
The "cloudstack-setup-databases" tool require Mysql to have `allow_remote_root` and `skip-name-resolve` set true to work.

```json
{
  "name": "cloudstack-lab",
  "description": "Cloudstack env.",
  "default_attributes": {
    "mysql": {
      "allow_remote_root": "true",
      "tunable": {
        "skip-name-resolve": "true"
      }
    }
  }
}
```

##### Create role
For a node that run cloudstack and is dependency (mysql, nfsserver):

```json
{
  "name": "co_cloudstack-lab",
  "description": "Cloudstack server.",
  "run_list": [
    "recipe[mysql::server]",
    "recipe[co-nfs::server]",
    "recipe[co-cloudstack]",
    "recipe[co-cloudstack::admin-apikey]",
    "recipe[co-cloudmonkey]"
  ]
}
```

##### bootstrap the node

```bash
knife bootstrap <your node FQDN or IP> \
    -r 'role[co_cloudstack-lab]' \
    -E cloudstack-lab \
    -x root \
    -P <your root password>
```

##### test it:
Access the url: <tt>http://node_ipaddress:8080/client</tt>



Recipes
-------

#### co-cloudstack::default
The default recipe will install apache cloudstack version based on the yum repo define in <tt>node['cloudstack']['repo']</tt>. the default recipe will include all sub recipes of co-cloudstack except the co-cloudstack::admin-apikey. 

include `co-cloudstack` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[co-cloudstack]"
  ]
}
```

#### co-cloudstack::admin-apikey
co-cloudstack::admin-apikey must add to the run_list of the node in order to generate admin account api_key and secret_key. The recipe will enable and use the integration api port to generage keys to admin account.

*co-cloudstack::admin-apikey will not disable the integration.api.port* once the chef-run is completed.

#### co-cloudstack::sys-tmpl
co-cloudstack::sys-tmpl will download system template VM's in the Secondary Storage path define in <tt>node['cloudstack']['secondary']['path']</tt>. By default the process will download system template VMs for XenServer, KVM and VMware. Once the download is completed, the recipe will add <tt>tags:template_uploaded</tt> to the node so templates will not be redownloaded every chef run. Also, if another node have the <tt>tags:template_uploaded</tt> within the environment of the node, it will not download system template VMs because the cookbook consider to be a peer of the other cloudstack server in is environment.

Default system templates:
```ruby
default['cloudstack']['hypervisor_tpl'] = {
  "xenserver" => "http://download.cloud.com/templates/acton/acton-systemvm-02062012.vhd.bz2", 
  "vmware" => "http://download.cloud.com/templates/burbank/burbank-systemvm-08012012.ova",
  "kvm" => "http://download.cloud.com/templates/acton/acton-systemvm-02062012.qcow2.bz2"
}
```

#### co-cloudstack::init-db
This recipe is automatically run by the co-cloudstack::default recipe. It will create and initialize the cloudstack databases using the <tt>/usr/bin/cloudstack-setup-databases</tt> tool. Once the database is initialize the recipe will add <tt>tags:db_init</tt> to the node to not re-execute cloudstack-setup-databases every chef run. If another host in the node environment have the <tt>tags:db_init</tt>, cloudstack-setup-databases will not be executed because the cookbook consider to be a peer of the other cloudstack server in is environment.

#### co-cloudstack::secondary-local-nfs
This recipe will run recipe co-nfs::export only if <tt>node['cloudstack']['secondary']['host'] == node["ipaddress"]</tt> to export the secondary storage as NFS.

#### co-cloudstack::vhd-util
This recipe download the tool vhd-util required to manage XenServer hosts that is not included in cloudstack RPMs.



Know issues and limitations
---------------------------

#### sudoers
Cloudstack require sudoers access so if you managed sudoers with Chef you need to add this in your configuration:
<tt>/etc/sudoers</tt>
```
cloud ALL =NOPASSWD : ALL
```
#### integration.api.port
The integration.api.port is not disabled once the admin keys are generated.

##### Primary Storage
You still have to configure a Primary storage for your zone. If you use LocalStorage on hypervisor, you will have to update Service offering for System VM and enable use of localstorage for systemVMs. <tt>system.vm.use.local.storage = true</tt>

##### Upgrade of Cloudstack
This cookbook does not support Upgrade action for cloudstack RPMs.


License and Authors
-------------------
- Authors:: Pierre-Luc Dion (<pdion@cloudops.com>)

```text
Copyright:: Copyright (c) 2014 CloudOps.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
