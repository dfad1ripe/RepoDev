# Perl modules

include_recipe 'cpanminus'

cpan_module 'Cpanel::JSON::XS' # note: requires gcc

cpan_module 'Su::Log'

cpan_module 'Digest::SHA1' # note: requires gcc

cpan_module 'File::Slurp'
