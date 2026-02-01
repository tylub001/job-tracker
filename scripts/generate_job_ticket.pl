#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use PDF::API2;

# ---------------------------------------------------------
# Validate input
# ---------------------------------------------------------
my ($job_id) = @ARGV;
die "Usage: perl generate_job_ticket.pl <job_id>\n" unless $job_id;

# ---------------------------------------------------------
# Database connection
# ---------------------------------------------------------
my $dbh = DBI->connect(
    "DBI:mysql:database=print_jobs_demo;host=127.0.0.1",
    "brittany",
    "Candy1988",
    { RaiseError => 1, PrintError => 0 }
);

# ---------------------------------------------------------
# Fetch job + customer + employee
# ---------------------------------------------------------
my $job_sql = q{
    SELECT j.id, j.job_name, j.status, j.due_date,
           c.name AS customer_name, c.email AS customer_email, c.phone AS customer_phone,
           e.name AS employee_name, e.email AS employee_email
    FROM jobs j
    JOIN customers c ON j.customer_id = c.id
    LEFT JOIN employees e ON j.employee_id = e.id
    WHERE j.id = ?
};

my $job_sth = $dbh->prepare($job_sql);
$job_sth->execute($job_id);
my $job = $job_sth->fetchrow_hashref;

die "Job ID $job_id not found.\n" unless $job;

# ---------------------------------------------------------
# Fetch job items
# ---------------------------------------------------------
my $items_sql = q{
    SELECT item_type, quantity, size, paper_type, color, finishing, notes
    FROM job_items
    WHERE job_id = ?
};

my $items_sth = $dbh->prepare($items_sql);
$items_sth->execute($job_id);

my @items;
while (my $row = $items_sth->fetchrow_hashref) {
    push @items, $row;
}

# ---------------------------------------------------------
# PDF Setup
# ---------------------------------------------------------
my $pdf  = PDF::API2->new();
my $page = $pdf->page;
$page->mediabox('Letter');

my $font = $pdf->corefont('Helvetica', -encoding => 'latin1');
my $text = $page->text;
$text->font($font, 12);

my $y = 750;

# ---------------------------------------------------------
# Helper: print a labeled line
# ---------------------------------------------------------
sub print_line {
    my ($label, $value) = @_;
    $value = defined $value && $value ne '' ? $value : 'N/A';

    $text->translate(50, $y);
    $text->text("$label: $value");
    $y -= 18;
}

# ---------------------------------------------------------
# Helper: new page when needed
# ---------------------------------------------------------
sub new_page {
    $page = $pdf->page;
    $page->mediabox('Letter');
    $text = $page->text;
    $text->font($font, 12);
    $y = 750;
}

# ---------------------------------------------------------
# Header
# ---------------------------------------------------------
$text->font($font, 16);
$text->translate(50, $y);
$text->text("Job Ticket");
$y -= 30;

$text->font($font, 12);

print_line("Job ID",            $job->{id});
print_line("Job Name",          $job->{job_name});
print_line("Status",            $job->{status});
print_line("Due Date",          $job->{due_date});
print_line("Customer",          $job->{customer_name});
print_line("Customer Email",    $job->{customer_email});
print_line("Customer Phone",    $job->{customer_phone});
print_line("Assigned Employee", $job->{employee_name});
print_line("Employee Email",    $job->{employee_email});

$y -= 20;

# ---------------------------------------------------------
# Job Items Section
# ---------------------------------------------------------
$text->font($font, 14);
$text->translate(50, $y);
$text->text("Job Items");
$y -= 25;

$text->font($font, 12);

foreach my $item (@items) {

    # Page break if needed
    new_page() if $y < 120;

    print_line("Item Type", $item->{item_type});
    print_line("Quantity",  $item->{quantity});
    print_line("Size",      $item->{size});
    print_line("Paper",     $item->{paper_type});
    print_line("Color",     $item->{color});
    print_line("Finishing", $item->{finishing});
    print_line("Notes",     $item->{notes});

    $y -= 10;  # extra spacing between items
}

# ---------------------------------------------------------
# Save PDF
# ---------------------------------------------------------
my $filename = "job_ticket_$job_id.pdf";
$pdf->saveas($filename);
$pdf->end();

print "PDF generated: $filename\n";

# Cleanup
$job_sth->finish;
$items_sth->finish;
$dbh->disconnect;
