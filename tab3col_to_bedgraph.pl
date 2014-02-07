#!/usr/bin/perl

# Description: This script converts a 3 columns tabular format, where columns are chr, start, value, to bedGraph format. Input file may be compressed as .gz.
# Coordinates in both input and bedGraph output are assumed to be 0-based (http://genome.ucsc.edu/goldenPath/help/bedgraph.html).

# Usage: tab3col_to_bedgraph.pl --tab input.tsv --bedgraph output.bedgraph
# --tab : specify input file in 3 columns tabular format, where columns are chr, start, value.
# --bedgraph : specify output file in bedgraph format.

# Credits: This script was written by Sebastien Vigneau (sebastien.vigneau@gmail.com) in Alexander Gimelbrant lab (Dana-Farber Cancer Institute).


use strict;
use warnings;
use Getopt::Long;

my $usage = "Usage: $0 --tab <infile.tsv> --bedgraph <outfile.bedgraph>";

# Parse command line arguments

my $infile; # 3 columns input file name
my $outfile; # bedgraph output file name

GetOptions (
  "tab=s" => \$infile,
  "bedgraph=s" => \$outfile,
) or die ("Error in command line arguments!\n$usage\n");

# Open input file. If it is compressed with gunzip, uncompress it.

if ($infile =~ /\.gz$/){
  open(IN,'-|',"gunzip -c $infile") || die "Could not open $infile: $!\n";
} else {
  open(IN,'<',$infile) || die "Could not open $infile: $!\n";
}

# Open output file.

open(OUT,'>',$outfile) || die "Could not open $outfile: $!\n";


# Conversion to bedgraph starts here.


# Declare variables.

my $chr;
my $start;
my $end;
my $val;
my $step;

my $prev_chr;
my $prev_start;
my $prev_end;
my $prev_val;


while (<IN>) {

  chomp;

  # Skip comment lines
  next if (/^#/);

  # Save previous line information 
  $prev_chr = $chr;
  $prev_start = $start;
  $prev_val = $val;

  # Parse relevant information in current line 
  # e.g: chr1 0 2
  ($chr, $start, $val) = split(/\t/);

  # Continue to next line if first line of file
  next if (! defined $prev_chr);

  # Update step size if current line belongs to same chromosome as previous line.
  # Otherwise, keep step unchanged.
  if ($chr eq $prev_chr) {
    $step = $start - $prev_start;
  }
 
  # Print information for previous line
  $prev_end = $prev_start + $step;
  print OUT "$prev_chr\t$prev_start\t$prev_end\t$prev_val\n";
}

# Print last line
$prev_chr = $chr;
$prev_start = $start;
$prev_end = $prev_start + $step;
$prev_val = $val;
print OUT "$prev_chr\t$prev_start\t$prev_end\t$prev_val\n";

close(IN);
close(OUT);

exit(0);
