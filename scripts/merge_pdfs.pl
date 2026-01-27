#!/usr/bin/env perl
use strict;
use warnings;
use PDF::API2;

# ------------------------------------------------------------
# merge_pdfs.pl
# Merge multiple PDF files into a single output PDF.
#
# Exit Codes:
#   0 = Success
#   1 = Invalid arguments
#   2 = Input file missing
#   3 = Failed to open input PDF
#   4 = Failed to write output PDF
# ------------------------------------------------------------

# --- Validate arguments ---
if (@ARGV < 3) {
    print "[ERROR] Usage: merge_pdfs.pl input1.pdf input2.pdf ... output.pdf\n";
    exit 1;
}

my $output = pop @ARGV;
my @inputs = @ARGV;

# --- Validate input files ---
foreach my $file (@inputs) {
    unless (-e $file) {
        print "[ERROR] Input file not found: $file\n";
        exit 2;
    }
}

print "[INFO] Starting PDF merge...\n";
print "[INFO] Output file will be: $output\n";

# --- Create new PDF ---
my $merged = PDF::API2->new();

# --- Process each input PDF ---
foreach my $pdf_file (@inputs) {
    print "[INFO] Processing: $pdf_file\n";

    my $pdf;
    eval {
        $pdf = PDF::API2->open($pdf_file);
    };
    if ($@ || !$pdf) {
        print "[ERROR] Failed to open PDF: $pdf_file\n";
        exit 3;
    }

    my $page_count = $pdf->pages;

    for my $page_num (1 .. $page_count) {
        eval {
            $merged->importpage($pdf, $page_num);
        };
        if ($@) {
            print "[ERROR] Failed to import page $page_num from $pdf_file\n";
            exit 3;
        }
    }
}

# --- Save merged PDF ---
eval {
    $merged->saveas($output);
    $merged->end();
};
if ($@) {
    print "[ERROR] Failed to write output PDF: $output\n";
    exit 4;
}

print "[SUCCESS] PDF merge complete. Saved to $output\n";
exit 0;
