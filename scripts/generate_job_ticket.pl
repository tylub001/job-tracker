#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use PDF::API2;

# -----------------------------
# Validate input
# -----------------------------
my ($job_id) = @ARGV;

if (!$job_id) {
    die "Usage: perl generate_job_ticket.pl <job_id>\n";
}

# -----------------------------
# Database connection
# -----------------------------
my $dbh = DBI->connect(
    "DBI:mysql:database=print_jobs_demo;host=127.0.0.1",
    "brittany",
    "Candy1988",
    { RaiseError => 1, PrintError => 0 }
);

# -----------------------------
# Fetch job + customer info
# -----------------------------
my $sql = q{
    SELECT j.id, j.job_name, j.status, j.due_date,
           c.name AS customer_name, c.email, c.phone
    FROM jobs j
    JOIN customers c ON j.customer_id = c.id
    WHERE j.id = ?
};

my $sth = $dbh->prepare($sql);
$sth->execute($job_id);

my $job = $sth->fetchrow_hashref;

if (!$job) {
    die "Job ID $job_id not found.\n";
}

# -----------------------------
# Create PDF
# -----------------------------
my $pdf = PDF::API2->new();
my $page = $pdf->page;
$page->mediabox('Letter');

my $font = $pdf->corefont('Helvetica', -encoding => 'latin1');

my $text = $page->text;
$text->font($font, 14);
$text->translate(50, 750);
$text->text("Job Ticket");

$text->font($font, 12);

my $y = 720;

sub line {
    my ($label, $value) = @_;
    $text->translate(50, $y);
    $text->text("$label: $value");
    $y -= 20;
}

line("Job ID",         $job->{id});
line("Customer",       $job->{customer_name});
line("Job Name",       $job->{job_name});
line("Status",         $job->{status});
line("Due Date",       $job->{due_date} // 'N/A');
line("Customer Email", $job->{email});
line("Customer Phone", $job->{phone});

# -----------------------------
# Save PDF
# -----------------------------
my $filename = "job_ticket_$job_id.pdf";
$pdf->saveas($filename);
$pdf->end();

print "PDF generated: $filename\n";

# Cleanup
$sth->finish;
$dbh->disconnect;
