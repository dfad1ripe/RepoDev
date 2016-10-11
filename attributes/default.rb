############################################################
#
# Parameters that you might want to change first of all
#

# External URL of the repository
default['Repo']['web_prefix'] = 'http://repodev/'

############################################################
#
# Parameters that you might want to leave 'as is'
#

# Base dir
default['Repo']['base_dir'] = '/opt/repo/'

# Subdir for web frontend
default['Repo']['web_dir'] = 'www/'

# FTP related parameters
default['proftpd']['conf']['server_name'] = 'Repo FTP Server'
default['Repo']['ftp_user'] = 'devops'
default['Repo']['ftp_pass'] = 'devops'
