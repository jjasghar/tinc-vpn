# default.rb
# set the netname here, the vpn-network name
default['tinc']['netname'] = 'netname'

# set a tunnel interface here
default['tinc']['interface'] = 'tun0'

# your vpn ip you want
default['tinc']['ip'] = '10.0.0.1'

# your subnet you want to use (number)
default['tinc']['subnet'] = '32'

# the subnet mask for the interface
default['tinc']['mask'] = '255.255.255.0'
