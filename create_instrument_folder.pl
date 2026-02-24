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
 
my $instrument = "TBN1";
my $src_folder = "/Users/ralf/Dropbox/BBB-Noten/01_Titel-Sorted";  
my $dst_folder = "../instruments/$instrument";  	 
my $verbose = 0;
my $sim = 1;
my $help = 0;
my $usage_string = "Usage: perl $0 --src './music_sheets' --dst './instr_folder' --instrument 'TBN3'";

GetOptions ("src=s" => \$src_folder,    # string
            "dst=s" => \$dst_folder,   
            "instrument=s" => \$instrument,   
 	     	"verbose" => \$verbose,
			"sim" => \$sim,
	     	"help" => \$help)
or die "$usage_string \n";

my @instruments = (
	"CONDUCTOR",
	"FULL-SCORE",
	"VOCAL",
	"RHYTH-BASS",
	"RHYTH-DRUMS",
	"RHYTH-GUITAR",
	"RHYTH-PERC",
	"RHYTH-PIANO",
	"RHYTH-SYNTH",
	"SAX-ALT1",
	"SAX-ALT2",
	"SAX-BARI",
	"SAX-SOPRAN",
	"SAX-TEN1",
	"SAX-TEN2",
	"TBN1",
	"TBN2",
	"TBN3",
	"TBN4",
	"TBN5",
	"TPT1",
	"TPT2",
	"TPT3",
	"TPT4",
	"TPT5",
	"FLGH",
	"CLARINET",
	"BASSCLARINET",
	"FLUTE2",
	"TRACK"
);

my $noi = scalar @instruments;

!$help or die "$usage_string\nValid instruments are: @instruments\n";

my @to_scan = grep(/$instrument/,@instruments);
my $size;
if ($size = scalar @to_scan) {
	print "INFO: Looking for @to_scan ($size instruments from $noi)\n"; 
} else {
	print "'$instrument' is not a valid instrument.\n";
	print "Valid instruments are: @instruments\n";
	die;
}
my $create_csv = ($noi == $size); 

if ( -d $dst_folder ) {
    print "WARNING: $dst_folder exists, files will be overwritten!\n" if $verbose;
} else {
    mkdir($dst_folder) or die "$!";
}

my @folders;
if ( -e $src_folder ) {
	print "INFO: Detecting folders to scan in $src_folder ...\n" if $verbose;
	opendir(DIR, $src_folder);
	my @dirs = sort readdir(DIR);
	closedir(DIR);
	foreach my $dir (@dirs) {
		next if (!-d "$src_folder/$dir");
		push (@folders,$dir) if $dir !~ m/^(\.|#|ZZZ)|00_|10_|2026/;
	}
} else {
	die "source directory '$src_folder' does not exist. Execution aborted.\n";
}

my %all_titles;
foreach $instrument (@to_scan) {
	$all_titles{"#instr_name"}{$instrument} = $instrument; 
}

foreach $instrument (@to_scan)
{
	print "INFO: Searching for instrument '$instrument'\n";
	if ( -d "$dst_folder/$instrument" ) {
		print "WARNING: $dst_folder/$instrument exists, files will be overwritten!\n" if $verbose;
	} else {
		mkdir("$dst_folder/$instrument") or die "$!";
	}
	my $missing_sheets_file = "$dst_folder/$instrument/"."#missing_sheets.txt";
	open(my $fh, ">", $missing_sheets_file) or die "Can't open > $missing_sheets_file: $!";

	my $cnt=0;
	foreach my $title (sort @folders) {
		$cnt++;
		if (-d "$src_folder/$title" ) { #skip all files present in the $src_folder.
			if ($verbose) {
				print "$cnt:  processing '$src_folder/$title':\n";
			 } else {
				print ".";
			 }

			opendir(DIR, "$src_folder/$title");
			my @files = readdir(DIR);

			print "INFO: Looking for $title - $instrument\n" if $verbose;
			my @matches = grep(/\Q$title\E\s+-\s+$instrument(.*?)\.\w+/i, @files);

			if (!@matches) {
				print "WARNING: '$title - $instrument' sheet not found in $src_folder/$title\n" if $verbose;
				print $fh "'$title - $instrument' sheet not found in $src_folder/$title\n";	
				$all_titles{$title}{$instrument} = "-";	
			}
			else {
				foreach my $file (@matches) { #should acutally be only one :-)
					if ($file) {
						$all_titles{$title}{$instrument} = "+";	
						if (-e "$dst_folder/$instrument/$file") {
							print "INFO: $dst_folder/$instrument/$file already exists in destination\n" if $verbose;
							next;
						}; #take next file if file in destination already exists
						if (!$sim) {
							if (copy("$src_folder/$title/$file", "$dst_folder/$instrument/$file")) {
								print "INFO: $src_folder/$title/$file copied into $dst_folder/$instrument/$file\n" if $verbose;
							} else {
								print "ERROR: Copying of $src_folder/$title/$file into $dst_folder/$instrument/$file failed: $!\n";
							}	
						} else {
							print "copy(\"$src_folder/$title/$file\", \"$dst_folder/$instrument/$file\")\n";
						}
					}
				}
			}
			closedir(DIR);
		}
	}
	close($fh);
}

my$csv_fh;
if ($create_csv){
	open ($csv_fh, ">", "$dst_folder/all_sheets.csv") or die "Cannot open all_sheets.csv $!";
} else {
	open ($csv_fh, ">", "$dst_folder/check.csv") or die "Cannot open check.csv $!";
}
# print the whole thing somewhat sorted
foreach my $title ( sort keys %all_titles ) {
	print $csv_fh "$title";
	for my $instr ( sort keys $all_titles{$title}->%* ) {
		print $csv_fh ";$all_titles{$title}{$instr}";
	}
	print $csv_fh "\n";
}
close $csv_fh;


