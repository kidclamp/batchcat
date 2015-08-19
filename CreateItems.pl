##This is my first Perl project.  I didn't do a lot of error catching as I
##am just trying to get the job done for myself.
##This code assumes your input barcodes are in a txt list, old barcode followed
##by new barcode i.e (as you can see we are moving from 6 to 14 digits:
##203933
##3VTKGHAV500066
##203934
##3VTKGHAV500067
##203935
##3VTKGHAV500068
##203936
##3VTKGHAV500069
##203938
##3VTKGHAV500070
##203939
##3VTKGHAV500071

use strict;
use warnings;
use MARC::Record; ##You need the MARC::Record package
use MARC::Batch;
use Getopt::Std;

my %options=();
getopts("hf", \%options);
print "-h $options{h}\n" if defined $options{h};


my $numArgs = $#ARGV +1;
if ($numArgs!=2){
die "Correct usage: perl CreateItems.pl [-f] \\path\\to\\barcode.file \\path\\to\\records.marc\n" ;
}

my $barcfile=$ARGV[0]; ##File location of yourBarcode list in text format
my $marcfile=$ARGV[1]; ##File location of your MARC records (in USMARC format)
die "Could not open MARC file\n" unless (-f $marcfile);
  my $inbatch = MARC::Batch->new('USMARC', $marcfile); ##Load the MARC records


##Reads in the barcode file or gives error
open(DAT, $barcfile) || die "Could not open barcode file!\n" ;
my @barcs=<DAT>;
close(DAT);

my $barcslen=@barcs; ##Get number of barcodes

open my $ImportRecords, '>', $marcfile.'-toimport.mrc' or die $1;
open my $Unmatched,'>',$barcfile.'-unmatched.txt' or die $1;

binmode($ImportRecords,':utf8');


#Reads through all the records in the file
while (my $record = $inbatch->next()) {
	my $updated = 0; #Reset flag to know if the current record has been changed
	##Get the holdings field of the current record
	my @RecordISBN=$record->field('020');
	##Get the barcode of the current marc record
	foreach my $RecordISBN (@RecordISBN) {
		my $marcISBN=$RecordISBN->subfield('a');
		if($marcISBN !~'^978'){
		    my @isbnchars=split("",$marcISBN);
		    my $checkdigit=(10-(38+($isbnchars[0]+$isbnchars[2]+$isbnchars[4]+$isbnchars[6]+$isbnchars[8])*3 +($isbnchars[1]+$isbnchars[3]+$isbnchars[5]+$isbnchars[7]))%10)%10;
		    my $marcNormISBN = join "", "978",substr($marcISBN,0,9),$checkdigit;
			$marcISBN=$marcNormISBN;
			}
		
		for (my $i=0;($i<$barcslen)&&($updated==0);$i=$i+2){
			##We are going to check every barcode on our filefor each MARC record.
			chomp($barcs[$i]);
			chomp($barcs[$i+1]);
			if($marcISBN eq $barcs[$i]){ ##Have we found a match?
			    my $importrecord;
				if($options{f}){
				    $importrecord=$record->clone();
					my @localdata = $importrecord->field('9..');
					$importrecord->delete_fields(@localdata);
				}
				else{
				    $importrecord=MARC::Record->new();
					$importrecord->append_fields($record->field('100'),$record->field('245'),$record->field('999'));
				}
                my $cally='';
                if( defined( $record->subfield('952','o') )){$cally = $record->subfield('952','o'); }
                else { $cally = 'J ' . substr($record->subfield('082','a'), 0, index($record->subfield('082','a'), '/')) . ' ' . substr($record->subfield('100','a'),0,3); }
                                     
                                
				my $holdings= MARC::Field->new(
                    952, ' ', ' ',
                    'a' => 'VTKI',
                    'b' => 'VTKI',
					'o' => $cally,
					'p' => $barcs[$i+1]
                     );
				$importrecord->insert_fields_ordered($holdings);
				print $ImportRecords $importrecord->as_usmarc(); ##Record this barcode as changed
				##I use the above file to delete the old holding records
				$barcs[$i]='NOPE'; ##This barcode is done, cross it off
				$barcs[($i+1)]='NOPE';
				$updated = 1; ##Flag to say we updated the record
			}
		}
	}
	#if ($updated == 0) { print OLDOUT $record->as_usmarc();}## Save as unchanged
	#else { print NEWOUT $record->as_usmarc();} ##Save this record as changed
}

##Now that we have checked each record, let's figure out which barcodes did
##not match up.
for (my $i=0;$i<$barcslen;$i=$i+2) {
  if($barcs[$i]!~'NOPE'){
  print $Unmatched $barcs[$i],"\n",$barcs[$i+1],"\n";
  }
}



