include_recipe 'iptables::default'

iptables_rule 'iptables_http' do
  action :enable
end

iptables_rule 'iptables_ftp' do
  action :enable
end
