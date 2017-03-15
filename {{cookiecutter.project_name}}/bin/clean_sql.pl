#!/usr/bin/perl -wnl

# /^CREATE TABLE/ and print and next;
if( /^CREATE TABLE/ ) {
	$tname = $_;
	$tname =~ s/^CREATE TABLE (\w+) \(/$1/;
	print and next;
}
/^\);/ and print and next;

# We want to retain the leading whitespace because it's nice
$w = $_;
$w =~ s/^(\s*).*/$1/;

# Data type is fine as is
$t = $_;
$t =~ s/.*" //;

# The field name itself
$f = $_;
$f =~ s/^\s*"(.+)"\s.*/$1/;		# Extract things between quotes
$f =~ s/ /_/g;					# Use underscores to make sql easier
$f =~ s/~rq_/_/;				# The reporter quant stuff is noise
$f =~ s/\?//g;					# Collapsed? column is noisy
$f =~ s|/|_|g;					# unique/razor needs a rename
$f =~ s/PeptideSequence/peptide_sequence/; # Peptide tables
$f =~ y/A-Z/a-z/;	  # Make uniform lower case for easier sql queries

print($w . $f . " " .  $t);

