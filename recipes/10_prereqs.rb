#
# First, disable selinux as the community code for MySQL requires

include_recipe 'selinux::disabled'

#
# Install additional packages
# unzip: to analyze zip files
# gcc: to build some CPAN Perl modules
%w(unzip gcc).each do |pkg|
  package pkg do
    action :install
  end
end

#
# Create user & group for handling repo server

group 'devops' do
  action :create
  append false
end

user 'devops' do
  action :create
  home '/home/devops'
  shell '/bin/bash'
  password '$1$nkcLJNGX$lsux6kr9wJ4XJabcyoj3t/'	# devops
  gid 'devops'
end

directory '/home/devops' do
  owner 'devops'
  group 'devops'
  mode '0700'
  action :create
end

#
# Create directory structure for the repo

base_dir = node['Repo']['base_dir']
directory base_dir do
  owner 'devops'
  group 'devops'
  mode '0755'
  action :create
end

directory base_dir + 'inbox' do
  owner 'devops'
  group 'devops'
  mode '0755'
  action :create
end

web_dir = base_dir + node['Repo']['web_dir']
directory web_dir do
  owner 'devops'
  group 'devops'
  mode '0755'
  action :create
end

directory web_dir + 'vagrant' do
  owner 'devops'
  group 'devops'
  mode '0755'
  action :create
end

directory web_dir + 'vagrant/boxes' do
  owner 'devops'
  group 'devops'
  mode '0755'
  action :create
end
