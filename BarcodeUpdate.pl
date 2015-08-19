use strict;
use warnings;
use MARC::Batch; ##You need the MARC::Record package
use Business::ISBN;

my $numArgs = $#ARGV +1;
if ($numArgs!=1){
die "Correct usage: perl barcodeUpdate.pl \\path\\to\\barcode.file\n" ;
}
die "Could not open barcode file\n" unless (-f $ARGV[0]);

my $barcfile=$ARGV[0]; ##File location of yourBarcode list in text format


##Reads in the barcode file or gives error
open(DAT, $barcfile) || die("Could not open file!");
my @barcs=<DAT>;
close(DAT);

my $barcslen=@barcs; ##Get number of barcodes
##This is the output file for successfully updated records
open my $ISBNsout, '>', $barcfile.'-ISBNs.txt' or die $1;
##This is the output file for ISBNs
open my $NormedFile, '>', $barcfile.'-Norm.txt' or die $1;
##Output Norm-ISBNs and barcodes stripped of errors
open my $Error,'>', $barcfile.'-Err.txt' or die $1;
##Output problem pairs

for (my $i=0;($i<$barcslen);$i=$i+2){
    my $testISBN=Business::ISBN->new($barcs[$i]);
	if (! defined $testISBN){
	  print $Error $barcs[$i],$barcs[$i+1];
	  next;
	  }
        if (uc(substr($barcs[$i+1],0,5)) ne '3VTKI'){ print $barcs[$i],$barcs[$i+1]; die "File Error";}
	print $ISBNsout $testISBN->as_isbn10()->isbn(),"\n", $testISBN->as_isbn13()->isbn(),"\n";
	print $NormedFile $testISBN->as_isbn13()->isbn(),"\n",$barcs[$i+1];
	}
	


