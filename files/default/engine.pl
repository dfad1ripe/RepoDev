#!/usr/bin/perl

use strict;
use Config;
use Su::Log;
my $LogLevel = 'info'; # set to 'debug' for more verbosity
use Cpanel::JSON::XS;
use Digest::SHA1;
use File::Copy;
use File::Slurp;

############ Config section START ############

# Directories
if ($Config::Config{osname} =~ m/MSWin/) {
  our $Inbox = 'C:/devops/RepoEngine/Inbox/';
  our $Outbox = 'C:/devops/RepoEngine/Outbox/';
  our $TempDir = 'C:/devops/RepoEngine/Temp/';
} else {
  our $Inbox = '/opt/repo/Inbox/';
  our $Outbox = '/opt/repo/www/vagrant/';
  our $TempDir = '/tmp/';
}

our $BoxDir = $::Outbox . 'boxes/';
our $LockFile = $::TempDir . 'repo.lock';

# Archivers usage
if ($Config::Config{osname} =~ m/MSWin/) {
  our $Unzip = 'C:\opscode\chefdk\embedded\git\usr\bin\unzip.exe';
  our $Tar = 'C:\opscode\chefdk\bin\tar.exe';
} else {
  our $Unzip = '/usr/bin/unzip';
  our $Tar = '/bin/tar';
}

############ Config section END ############
############ Description section START ############

our $Box = {
  name => '',
  description => '',
  versions => [{
    version => '0.0.0',
    providers => [{
      name => 'virtualbox',	# default
      url => '',
      checksum_type => 'sha1',
      checksum => ''
    }],
  }],
};

############ Description section END ############
############ Function section START ############

sub Lock {
  $::log->debug(" Attempting to acquire a lock");
  if (-e $::LockFile) {
    $::log->debug(" Lock file exists");
    return 1;
  } else {
    $::log->debug(' Creating lock file');
    open LOCK, '>', $::LockFile or die $!;
    print LOCK '...';
    close LOCK;
    $::log->debug(" Created lock file successfully");
    return 0;
  }
}

sub Unlock {
  $::log->debug(" Deleting a lock");
  unlink $::LockFile;
  $::log->debug(" Deleted a lock");
}

############ Function section END ############
############ Main ############

# Initiate log system
our $log = Su::Log->new;
$log->set_global_log_level($LogLevel);
$log->log_handler('engine.log');
$log->info('###################################');
$log->info(" Repo engine started.");

# Try to get lock; if lock file exists - exit immideately.
if (Lock() != 0) {
  $log->info(" Lock file exists, exiting.");
  print("Lock file exists, exiting.\n");
  exit;
}

# Do we have new files to process?
$log->info(" Checking Inbox.");

opendir my $InboxDir, $::Inbox or die "Cannot open Inbox at $::Inbox: $!";
my @InFiles =  grep { !/^\.+$/ } readdir $InboxDir; # exclude "." and ".." entries
closedir $InboxDir;

$log->info(" Files found: " . scalar @InFiles . "  @InFiles");

# If the list is not empty, we pick 1st element for processing.
if (scalar @InFiles > 0) {
  my $BoxFileName = $::Inbox . @InFiles[0];
  $log->info(" Processing $BoxFileName");
  print "Processing $BoxFileName\n";

  # Is it zip or tgz?
  my $IsZip = 0;
  my $IsTgz = 0;

  $log->debug(" Executing $::Unzip -t $BoxFileName > nul 2> nul");
  system("$::Unzip -t $BoxFileName > nul 2> nul");
  if ($? == 0) {
    $log->info(" $BoxFileName is ZIP archive.");
    print "$BoxFileName is ZIP archive.\n";
    $IsZip = 1;
  } else {
    $log->debug(" Executing $::Tar -tzf $BoxFileName > nul 2> nul");
    system("$::Tar -tzf $BoxFileName > nul 2> nul");
    if ($? == 0) {
      $log->info(" $BoxFileName is TGZ archive.");
      print "$BoxFileName is TGZ archive.\n";
      $IsTgz = 1;
    }
  }

  # If it is neither ZIP nor TGZ, delete the file, unlock and exit.
  if (($IsZip == 0) && ($IsTgz == 0)) {
    $log->info(" $BoxFileName is neither ZIP nor TGZ, deleting.");
    print "$BoxFileName is neither ZIP nor TGZ, deleting.\n";
    unlink $BoxFileName or die "Cannot delete $BoxFileName: $!\n";
    Unlock();
    exit;
  }

  # As this is an archive, at least we can set it's name and
  # initial description.
  $::Box->{'name'} = @InFiles[0]; # Use filename as initial box name
  $::Box->{'name'} =~ s/\.box$//; # \
  $::Box->{'name'} =~ s/\.tgz$//; #  > Remove suffixes
  $::Box->{'name'} =~ s/\.zip$//; # /
  $::Box->{'description'} = "Box added as $::Box->{'name'}";

  # Extract metadata
  if ($IsZip == 1) {
    our $command = "$::Unzip $BoxFileName metadata.json -d $::TempDir > nul 2> nul";
  } else {
    our $command = "$::Tar -xzf $BoxFileName -C $::TempDir metadata.json > nul 2> nul";
  }
  $log->debug(" Extracting metadata with command:");
  $log->debug(" $::command");
  system($::command);
  if ($? == 0) {	# metadata extracted successfully
    $log->info(" Metadata extracted");
    print "Metadata extracted\n";

    # Read metadata.json
    open MDATA, '<', ($::TempDir . "metadata.json") or die $!;
    my $rawmetadata = <MDATA>;
    close MDATA;
    $log->debug(" Raw metadata:");
    $log->debug(" " . $rawmetadata);
    # Delete the file
    unlink($::TempDir . "metadata.json");

    our $metadata = decode_json $rawmetadata;

    # For future: deeper box analysis.
    # Do we have a box for virtualbox?
    # If yes, read box.ovf (XML) and get the following data:
    # - VirtualSystem ovf:id as box name;
    # - VirtualSystem Info as description.

    # Correct provider data
    if (length($metadata->{'provider'}) > 0) {
      $log->info(" Provider: $metadata->{'provider'}");
      $::Box->{'versions'}[0]->{'providers'}[0]->{'name'} = $metadata->{'provider'};
    }

  } else {
    $log->info(" Metadata does not exist");
    print "Metadata does not exist\n";
  }

  # Calculate checksum
  $log->debug(" Calculating SHA1 checksum");
  open BOX, '<', $BoxFileName or die $!;
  my $sha1 = Digest::SHA1->new;
  $sha1->addfile(*BOX);
  $::Box->{'versions'}[0]->{'providers'}[0]->{'checksum'} = $sha1->hexdigest;
  close BOX;
  $log->debug(" SHA1 checksum: $sha1->hexdigest");
  #print (encode_json $::Box, $Cpanel::JSON::XS::allow_nonref) . "\n\n";

  # Merge JSON descriptions
  $log->debug(" Reading existing JSON catalog");
  #open JSON, '<', $::Outbox . 'boxes.json' or die "Cannot open boxes.json: $!";
  #my $OldJSON = <JSON>;
  #close JSON;
  $log->debug(" Merging JSON objects");
  #print "$OldJSON\n";
  my $DecodedOldJSON = decode_json(read_file($::Outbox . 'boxes.json'));
  push my @NewCatalog, @{$DecodedOldJSON};

  # Move box file to Outbox
  my $NewBoxFileName = $::Outbox . 'boxes/'. @InFiles[0];
  #move($BoxFileName, $NewBoxFileName) or die("Cannot move $BoxFileName to destination $NewBoxFileName: $!");
}

# Finally, remove the lock.
Unlock();
