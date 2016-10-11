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
    <td>Username for FTP transfers (not used currently)</td>
    <td><tt>devops</tt></td>
  </tr>
  <tr>
    <td><tt>['Repo']['ftp_pass']</tt></td>
    <td>String</td>
    <td>Password of FTP user (not used currently)</td>
    <td><tt>devops</tt></td>
  </tr>
</table>

## Usage

JSON data about existing boxes is available at:
`http://<hostname:port>/vagrant/boxes.json`.

To use it, specify the following parameter in Vagrantfile:
`config.vm.box_url = 'http://<hostname:port>/vagrant/boxes.json'` 

### A workflow to add new boxes:

1. A box is uploaded to Inbox dir (`['Repo']['base_dir']/Inbox`) by FTP or SCP. 
2. A scheduled task analyzes the box, (archive format, metadata, checksum).
3. If the analysis was successful, the box is placed to web share by the script, and corresponding JSON data is added.

### How it works in details:

- On each pass, the script analyzes one file in Inbox directory.
- A lock file (repo.lock) is created in Temp directory when the script is started. Once the script completes, the lock is removed. The script exits immediately if lock file exists already, allowing the previous instance to finish first.
- If the script fails, lock file is NOT removed, thus avoiding repeated runs that would fail with same error message. Instead, lock file should be removed manually after the issue is solved.
- File format is checked. Box is treated as valid if it is ZIP or TGZ archive.
- Incoming file that is not recognized as valid box on previous step is **deleted** so the script would be able to analyze another file at next scheduled run.
- metadata.json is extracted and analyzed if it exists. *Note: In bento boxes that I checked, this file keeps an information about VM provider only. I suppose that this may vary, keep box version etc, but I have not seen other options yet, so did not add other checks.*
- SHA1 checksum is calculated.
- The box is moved to web share under Outbox directory.
- JSON description of the box is added to existing catalog (boxes.json).

### Logging and debugging

Log file `engine.log` is created in current working directory.
The script uses Su::Log module for logging purposes. Default log level is `info`. To get more verbose log output, set `$LogLevel` variable in the script to `debug`.   

## ToDo:

- Add provider specific analysis. Particularly, for VirtualBox, analyze `box.ovf` to extract values for box name and description.
- Add `syslog` support. *Note: log rotation is not implemented in the script.* 

## License and Authors

Author:: Dmytro Fadyeyenko (dmytro.fadyeyenko@globallogic.com)
