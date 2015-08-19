# batchcat
Simple perl scripts to aid in batch cataloging a collection

There are two basic scripts here:
1 - BarcodeUpdate.pl:  This accepts a path to a file that contains alternating lines of ISBNS and itembarcodes
    i.e.:
    9780061241086
    3VSPI035204512
    9781476710792
    3VSPI025551860
    ...
    The script outputs three files: Filename-ISBNs.txt | Filename-Norm.txt | Filename-Err.txt
    ISBNs contains all the isbns (in both 10 and 13 digit version)
    Norm contains ISBNs / Barcodes but all ISBNs are 13 digit
    Err contains errors.
    Error handling is minimal, mostly dies and makes you clean the file and rerun
    
2 - CreateItems.pl: This accepts a MARC file and an ISBN/barcode file (as above) and goes through the ISBNs, attempting to match     those in the file and create item records (formatted for Koha) and attach to the record.  It outputs two files       
    Filename-ToImport.mrc (containing MARC records with items) and Filename-unmatche.txt (containing ISBN/barcode pairs that     were not matched)
    It accepts one command line option: f
      Without f the generated MARC records contain only the biblionumber and the items, this was used for local imports into       our local Koha system matching only on biblionumber
      With f the generated marc are full records

To-do: LOTS!
  - The current version expects you to use MARCedit (or tool of your choice) to get records from Z39.50 sources, using the isbn file.  This can, and should, be automated.  Ideally you would put your sources into a config file and the script would search each ISBN in desired priority until a match was found
  - The script should be combined, if you can auto search you can auto generate items
  - The script should handle ISBNs that don't convert from 10-13 digit and vice versa
  - Call number patterns should be configurable and not hard coded as current
