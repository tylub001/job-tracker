#!/usr/bin/env perl
use strict;
use warnings;
use PDF::API2;

# ------------------------------------------------------------
# validate_pdf.pl
# Validate a PDF file for basic structural integrity.
#
# Exit Codes:
#   0 = Valid PDF
#   1 = Invalid arguments
#   2 = File not found
#   3 = Not a PDF (bad header)
#   4 = Failed to open PDF (corrupt or unreadable)
#   5 = Zero-page PDF (invalid)
# ------------------------------------------------------------

if (@ARGV != 1) {
    print "[ERROR] Usage: validate_pdf.pl file.pdf\n";
    exit 1;
}

my $file = $ARGV[0];

# --- Check file exists ---
unless (-e $file) {
    print "[ERROR] File not found: $file\n";
    exit 2;
}

# --- Check PDF header ---
open my $fh, '<', $file or do {
    print "[ERROR] Cannot open file: $file\n";
    exit 4;
};

read $fh, my $header, 5;
close $fh;

unless ($header =~ /^%PDF-/) {
    print "[ERROR] Invalid PDF header in $file\n";
    exit 3;
}

# --- Try opening with PDF::API2 ---
my $pdf;
eval {
    $pdf = PDF::API2->open($file);
};
if ($@ || !$pdf) {
    print "[ERROR] PDF::API2 failed to read $file (corrupt or unsupported)\n";
    exit 4;
}

# --- Check page count ---
my $pages = $pdf->pages;
if ($pages < 1) {
    print "[ERROR] PDF has zero pages: $file\n";
    exit 5;
}

print "[SUCCESS] PDF is valid: $file ($pages pages)\n";
exit 0;
