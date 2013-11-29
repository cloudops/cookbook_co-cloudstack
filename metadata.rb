name             'co-cloudstack'
maintainer       'CloudOps.com'
maintainer_email 'pdion@cloudops.com'
license          'Apache 2.0'
description      'Installs/Configures co-cloudstack'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"

%w{ fedora redhat centos }.each do |os|
  supports os
end

depends "co-nfs"
depends "database"

recipe "co-cloudstack::default", "Installs and configures Apache Cloudstack"
recipe "co-cloudstack::admin-apikey", "Generate api and secret keys of admin account and store them in attributes"
recipe "co-cloudstack::init-db", "Create and Initialized Cloudstack databases"
recipe "co-cloudstack::secondary-local-nfs", "run recipe nfs::export if secondary storage is local"
recipe "co-cloudstack::sys-tmpl", "Download system VM templates"
recipe "co-cloudstack::vhd-util", "Download vhd-util scripts (no-dist license)"
