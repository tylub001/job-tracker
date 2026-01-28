#!/usr/bin/env perl
use strict;
use warnings;
use DBI;

# Connect to database
my $dbh = DBI->connect(
    "DBI:mysql:database=print_jobs_demo;host=127.0.0.1",
    "brittany",
    "Candy1988",
    { RaiseError => 1, PrintError => 0 }
);

# Fetch all job IDs
my $sth = $dbh->prepare("SELECT id FROM jobs");
$sth->execute();

while (my ($job_id) = $sth->fetchrow_array) {
    print "[INFO] Generating ticket for job $job_id\n";
    system("perl /home/dream/job-tracker/scripts/generate_job_ticket.pl $job_id");
}

$sth->finish;
$dbh->disconnect;

print "[INFO] All tickets generated.\n";
