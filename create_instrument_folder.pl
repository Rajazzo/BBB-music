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
 
my $src_folder = "./titles";  
my $dst_folder = "./instruments"; 	 
my $instrument = "TBN3";
my $verbose = 0;
my $help = 0;
my $usage_string = "Usage: perl $0 --src './titles' --dst './instruments' --instrument 'TBN3' --verbose > ./log.txt";

GetOptions ("src=s" => \$src_folder,    # string
             "dst=s" => \$dst_folder,   
             "instrument=s" => \$instrument,   
 	     "verbose" => \$verbose,
	     "help" => \$help)
or die "$usage_string \n";

!$help or die "$usage_string \n
For full list of instruments, see file: '~/Dropbox/BBB-Noten/01_Titel-Sorted/01_Titel-Sorted_NameConvention.txt'\n";

if ( -d $dst_folder ) {
    print "WARNING: $dst_folder exists, files will be overwritten!\n";
} else {
    mkdir($dst_folder) or die "$!";
}

my @folders;
if ( -e $src_folder ) {
	opendir(DIR, $src_folder);
	@folders = readdir(DIR);
	closedir(DIR);
} else {
	die "source directory '$src_folder' does not exist. Execution aborted.\n";
}


foreach my $folder (sort @folders) {
	if ($folder =~ /^(\.|#|ZZZ)|00_|10_|2026/) {
		print "Skipping special folder $folder\n";
		next;
	}; 
	if (-d $src_folder . "/" . $folder ) { #skip all files present in the $src_folder.
		print "processing $src_folder/$folder:   ";
		opendir(DIR, $src_folder . "/" . $folder);
		my @files =  grep(/$instrument/i, readdir(DIR));

		if (!@files) {
			print "WARNING: $instrument sheet not found in $src_folder/$folder!\n";		
		}
	
		foreach my $file (@files) { #should acutally be only one :-)
			if (-e $dst_folder . "/" . $file) {
				print "$dst_folder/$file already exists \n";
				next;
			}; #take next file if file in destination already exists
			if (copy($src_folder . "/" . $folder . "/" . $file, $dst_folder . "/" . $file)) {
				if ($verbose) {
					print "INFO: $src_folder/$folder/$file -> $dst_folder/$file\n";
				}
			} else {
				print "ERROR: Copy of $src_folder/$folder/$file to $dst_folder/$file failed: $!\n";
			}
		}
		closedir(DIR);
	}
}