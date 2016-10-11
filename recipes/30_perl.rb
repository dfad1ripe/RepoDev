# Perl modules

include_recipe 'cpanminus'

cpan_module 'Cpanel::JSON::XS' # note: requires gcc

cpan_module 'Su::Log'

cpan_module 'Digest::SHA1' # note: requires gcc

cpan_module 'File::Slurp'

# Place the engine script

template node['Repo']['base_dir'] + 'engine.pl' do
  source 'engine.erb'
  owner 'devops'
  group 'devops'
  mode '0774'
end

# Schedule a task for engine script
