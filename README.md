# RepoDev-cookbook

Local vagrant repository 

## Supported Platforms

Created and tested on Centos 6.8 only.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['Repo']['base_dir']</tt></td>
    <td>String</td>
    <td>Base installation directory</td>
    <td><tt>/opt/repo/</tt></td>
  </tr>
  <tr>
    <td><tt>['Repo']['web_dir']</tt></td>
    <td>String</td>
    <td>Subdirectory for web frontend</td>
    <td><tt>www/</tt></td>
  </tr>
  <tr>
    <td><tt>['Repo']['ftp_user']</tt></td>
    <td>String</td>
    <td>Username for FTP transfers</td>
    <td><tt>devops</tt></td>
  </tr>
  <tr>
    <td><tt>['Repo']['ftp_pass']</tt></td>
    <td>String</td>
    <td>Password of FTP user</td>
    <td><tt>devops</tt></td>
  </tr>
</table>

## Usage

JSON data about existing boxes is available at:
`http://<hostname:port>/vagrant/boxes.json`.

To use it, specify the following parameter in Vagrantfile:
`config.vm.box_url = 'http://<hostname:port>/vagrant/boxes.json'` 

Suggested workflow to add new boxes:

1. A box is uploaded to Inbox dir of FTP server.
2. A scheduled task analyzes the box, (archive format, metadata: name, version etc, checksum).
3. If the analysis was successful, the box is placed to web share, and
corresponding JSON data is added.  

## License and Authors

Author:: Dmytro Fadyeyenko (dmytro.fadyeyenko@globallogic.com)
