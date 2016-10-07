#
# Vagrant working directory

vagrant_dir = node['Repo']['base_dir'] + node['Repo']['web_dir'] +
              'vagrant/'


#
# Download initial box to a repo

bash 'Download one real box' do
  action :nothing
  cwd vagrant_dir + 'boxes/'
  code <<-EOH
    wget -c https://atlas.hashicorp.com/bento/boxes/centos-5.11/versions/2.2.9/providers/virtualbox.box
    mv virtualbox.box bento-centos-5.11.box
    EOH
  not_if { ::File.exists?(vagrant_dir + 'boxes/bento-centos-5.11.box') }
end

#
# Put initial description

cookbook_file vagrant_dir + 'boxes.json' do
  source 'boxes.json'
end