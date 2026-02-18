#!/usr/bin/perl
################################################################################
# Info:
# Checks if PDF is present for each instrument (see naming convention  
# \\\\nu02fs01.fe.de.bosch.com\\bbb\$\\08_Noten\\01 - Titel-Sorted - Namenskonvention.txt)
# Generates a CSV file of missing scans for each instrument.
# Import this file in Excel and filter for instrument or piece you are interested in.
# Caution: some instruments are only used in few pieces, e.g. not all pieces are 
# vocal.
#
# Author: Peter Munk
#
# Date: 2015-12-18
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
 
my $src_folder = "V:\\BBB-Noten\\01_Titel-Sorted";  
my @instruments = (
#"CONDUCTOR",
#"VOCAL",
#"RHYTH-BASS",
#"RHYTH-DRUMS",
#"RHYTH-GUITAR",
#"RHYTH-PERC",
#"RHYTH-PIANO",
#"RHYTH-SYNTH",
#"SAX-ALT1",
#"SAX-ALT2",
#"SAX-BARI",
#"SAX-SOPRAN",
#"SAX-TEN1",
#"SAX-TEN2",
#"TBN1",
"TBN2",
#"TBN3",
#"TBN4"
#"TBN5",
#"TPT1",
#"TPT2",
#"TPT3",
#"TPT4",
#"TPT5",
#"TUBA",
#"PICCOLO",
#"FLGH1",
#"FLGH2",
#"SOLO-TPT",
#"SOLO-TBN",
#"SOLO-SAX-ALT",
#"SOLO-SAX-TEN",
#"FRENCH-HORN1",
#"FRENCH-HORN2",
#"CLARINET",
#"BASSCLARINET",
#"FLUTE",
#"CHOIR-ALTO1",
#"CHOIR-ALTO2",
#"CHOIR-SOPRANO1",
#"CHOIR-SOPRANO2",
#"TRACK"
);
my $help = 0;

GetOptions ("src=s" => \$src_folder,    # string
			"help" => \$help)
or die "Usage: perl $0 --src \"V:\\BBB-Noten\\01 - Titel-Sorted\" > C:\\log.csv\n";

!$help or die "Usage: perl $0 --src \"V:\\BBB-Noten\\01 - Titel-Sorted\" > C:\\log.csv\n";

print "Reading ".$src_folder."\n";
opendir(DIR, $src_folder);
my @folders = readdir(DIR);
closedir(DIR);

print "Missing_PDF;Instrument\n";

foreach my $folder (sort @folders) {
	next if ($folder =~ /^\./ ); #skip the . and .. folders
	next if ($folder =~ /^#/ ); #skip folders starting with '#'
	if (-d $src_folder . "\\" . $folder ) { #skip all files present in the $src_folder.
		opendir(DIR, $src_folder . "\\" . $folder);
		my @files =  readdir(DIR);
		foreach my $instrument (@instruments) {
			my @scan = grep(/$instrument/i, @files);
			if (!@scan) {
				print "\"$folder\";\"$instrument\"\n";		
			}
		}
		closedir(DIR);
	}
}