#
# Cookbook Name:: tinc-vpn
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

hostname = node['hostname']
netname = node['tinc']['netname']

# if on debian_family make sure that the apt repos are up to date
if 'debian' == node['platform_family']
  include_recipe 'apt'
end

# install the package
package 'tinc' do
  action :install
end

# create the netname
directory "/etc/tinc/#{netname}/hosts" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

# template for configuration
template "/etc/tinc/#{netname}/tinc.conf" do
  source "tinc.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

# the hosts file for the network
template "/etc/tinc/#{netname}/hosts/#{hostname}" do
  source "hosts_tinc.erb"
  owner "root"
  group "root"
  mode "0644"
end

# create the private and public keys
bash "create public private keys" do
  user "root"
  cwd "/etc/tinc/#{netname}/"
  creates "/etc/tinc/#{netname}/rsa_key.priv"
  code <<-EOH
    STATUS=0
    sudo tincd -n #{netname} -K4096 || STATUS=1
    exit $STATUS
  EOH
end

# create the tinc-up script
template "/etc/tinc/#{netname}/tinc-up" do
  source "tinc-up.erb"
  owner "root"
  group "root"
  mode "0755"
end

# create the tinc-down script
template "/etc/tinc/#{netname}/tinc-down" do
  source "tinc-down.erb"
  owner "root"
  group "root"
  mode "0755"
end
