# Base dir
default['Repo']['base_dir'] = '/opt/repo/'

# Subdir for web frontend
default['Repo']['web_dir'] = 'www/'

# FTP related parameters
default['proftpd']['conf']['server_name'] = 'Repo FTP Server'
default['Repo']['ftp_user'] = 'devops'
default['Repo']['ftp_pass'] = 'devops'
