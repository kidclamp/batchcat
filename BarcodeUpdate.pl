#!/usr/bin/perl -w

# Copyright (C) 2013  WNickC
# Copyright (C) 2015  mtompset (Improved file handling, whitespace)
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# It is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use MARC::Batch; ##You need the MARC::Record package
use Business::ISBN;

my $numArgs = $#ARGV +1;
if ($numArgs!=1){
    die "Correct usage: perl $0 \\path\\to\\barcode.file\n" ;
}
die "Could not open barcode file\n" unless (-f $ARGV[0]);

my $barcfile=$ARGV[0]; ##File location of yourBarcode list in text format

## The file is expected to be alternating ISBN and barcodes.
##Reads in the barcode file or gives error
my @pairs;
open(DAT, $barcfile) || die("Could not open file!");
binmode(DAT, ":encoding(UTF-8)");
while (my $barcode=<DAT>) {
    $barcode =~ s/\r/\n/g;
    $barcode =~ s/\n\n/\n/g;
    my @data = split(/\n/,$barcode);
    push @pairs, @data;
}
close(DAT);

my $pairslen=@pairs; ##Get number of barcodes
##This is the output file for successfully updated records
open my $ISBNsout, '>', $barcfile.'-ISBNs.txt' or die $1;
##This is the output file for ISBNs
open my $NormedFile, '>', $barcfile.'-Norm.txt' or die $1;
##Output Norm-ISBNs and barcodes stripped of errors
open my $Error,'>', $barcfile.'-Err.txt' or die $1;
##Output problem pairs

for (my $i=0;($i<$pairslen);$i=$i+2){
    my $testISBN=Business::ISBN->new($pairs[$i]);
    if (! defined $testISBN){
        print $Error $pairs[$i],$pairs[$i+1];
        next;
    }
    if (uc(substr($pairs[$i+1],0,5)) ne '3VTKI'){ print $pairs[$i],$pairs[$i+1]; die "File Error";}
    print $ISBNsout $testISBN->as_isbn10()->isbn(),"\n", $testISBN->as_isbn13()->isbn(),"\n";
    print $NormedFile $testISBN->as_isbn13()->isbn(),"\n",$pairs[$i+1],"\n";
}
