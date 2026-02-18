#!/usr/bin/perl
################################################################################
# Info:
# Script to copy all PDFs of a specific instrument to a separate folder.
# Generates warnings for all missing PDFs for the specific instrument.
# Caution: there are some bugs concerning special characters, e.g. '.
#          Errors will be reported in such cases.
#  
#
# Author: Peter Munk
#
# Date: 2015-01-09
#
################################################################################

use strict;
use warnings;
use File::Copy;
use File::Basename;
use Getopt::Long;
use Data::Dumper; #Debug

# turn all warnings to fatal errors
local $SIG{__WARN__} = sub { die $_[0] };
 
my $src_folder = "\\\\nu02fs01.fe.de.bosch.com\\bbb\$\\08_Noten\\01 - Titel-Sorted";  
my $dst_folder = "C:\\BBB"; 		# or ".\\output";  
my $instrument = "TBN3";
my $verbose = 0;
my $help = 0;

GetOptions ("src=s" => \$src_folder,    # string
             "dst=s" => \$dst_folder,   
             "instrument=s" => \$instrument,   
 	     "verbose" => \$verbose,
	     "help" => \$help)
or die "Usage: perl $0 --src \"\\\\nu02fs01.fe.de.bosch.com\\bbb\$\\08_Noten\\01 - Titel-Sorted\" --dst C:\\BBB --instrument TBN3 --verbose > C:\\BBB\\log.txt\n";

!$help or die "Usage: perl $0 --src \"\\\\nu02fs01.fe.de.bosch.com\\bbb\$\\08_Noten\\01 - Titel-Sorted\" --dst C:\\BBB --instrument TBN3 --verbose > C:\\BBB\\log.txt\n
For full list of instruments, see file:\/\/nu02fs01.fe.de.bosch.com/bbb\$/08_Noten/01%20-%20Titel-Sorted%20-%20Namenskonvention.txt\n";

if ( -d $dst_folder ) {
    print "WARNING: $dst_folder exists, files will be overwritten!\n";
} else {
    mkdir($dst_folder) or die "$!";
}

opendir(DIR, $src_folder);
my @folders = readdir(DIR);
closedir(DIR);

foreach my $folder (@folders) {
	if (-d $src_folder . "\\" . $folder ) { #skip all files present in the $src_folder.

		opendir(DIR, $src_folder . "\\" . $folder);
		my @files =  grep(/$instrument/i, readdir(DIR));

		if (!@files) {
			print "WARNING: $instrument sheet not found in $src_folder\\$folder!\n";		
		}
	
		foreach my $file (@files) { #should acutally be only one :-)
			if (copy($src_folder . "\\" . $folder . "\\" . $file, $dst_folder . "\\" . $file)) {
				if ($verbose) {
					print "INFO: $src_folder\\$folder\\$file -> $dst_folder\\$file\n";
				}
			} else {
				print "ERROR: Copy of $src_folder\\$folder\\$file to $dst_folder\\$file failed: $!\n";
			}
		}
		closedir(DIR);
	}
}