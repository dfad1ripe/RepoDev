#
# First, install apache from the community code

include_recipe 'apache2'

# Place VirtualHost description to apache conf dir.

base_dir = node['Repo']['base_dir']
web_dir = base_dir + node['Repo']['web_dir']

web_app 'web_repo' do
  server_name 'repodev'
  server_alias 'repo'
  docroot web_dir
  directory_options 'Indexes'
end

#
# Install FTP server

include_recipe 'vsftpd'

# TODO: create FTP user
