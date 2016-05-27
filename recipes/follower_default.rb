#
# Cookbook Name:: tinc-vpn
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

hostname = node['hostname']
netname = node['tinc']['netname']

all_data = data_bag('tinc_followers')
node_data = Mash.new

all_data.each do |n|
  this_node = data_bag_item('tinc_followers', n)
  if this_node['hostname'] == hostname
    node_data = this_node
  end
end

include_recipe "tinc-vpn::bootstrap" unless node_data['hostname']

leader_node = data_bag_item('tinc', 'leader')

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
  variables({:leader_name => leader_node['name'],
    :node_name => node_data['name']})
end

# the hosts file for the network
template "/etc/tinc/#{netname}/hosts/#{node_data['name']}" do
  source "hosts_tinc.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({:public_key => node_data['public_key'],
    :ip => node_data['vpn_ip'],
    :subnet => node_data['subnet']})
end

if node_data['private_key']
  file "/etc/tinc/#{netname}/rsa_key.priv" do
    content node_data['private_key']
  end
  file "/etc/tinc/#{netname}/rsa_key.pub" do
    content node_data['public_key']
  end
else
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

  #TODO: Save keys to node databag
end

# create the tinc-up script
template "/etc/tinc/#{netname}/tinc-up" do
  source "tinc-up.erb"
  owner "root"
  group "root"
  mode "0755"
  variables ({:ip => node_data['vpn_ip']})
end

# create the tinc-down script
template "/etc/tinc/#{netname}/tinc-down" do
  source "tinc-down.erb"
  owner "root"
  group "root"
  mode "0755"
end
