#!/usr/bin/perl 


$FILE = "result.txt";

my $a;

open (F, "<".$FILE);

  while (<F>) {
	chomp;
	($ref_Int, $ref_Status) = split(/;/);

	$ref_Int =~ s/_/;/;
	
	my $LEN = length($ref_Status);
	my $VAL = 0;

	@status = split (//, $ref_Status);	

	foreach $a (@status) {

		if ( $a == 1 ) { $VAL++; }
	}

	print $ref_Int .";". $LEN .";". $VAL ."\n";

  }
close F; 

# ============================================================================

