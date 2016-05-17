# make sure that tinc is installed
describe package('tinc') do
  it { should be_installed }
end

# make sure that the config files are there
describe file('/etc/tinc/netname/tinc.conf') do
  it { should be_file }
end

# make sure that the directory is there
describe file('/etc/tinc/netname/hosts') do
  it { should be_directory }
end

# make sure that the tinc-up is there
describe file('/etc/tinc/netname/tinc-up') do
  it { should be_file }
  it { should be_executable }
end

# make sure that the tinc-down is there
describe file('/etc/tinc/netname/tinc-down') do
  it { should be_file }
  it { should be_executable }
end

# make sure that the private key was created
describe file('/etc/tinc/netname/rsa_key.priv') do
  it { should be_file }
end
