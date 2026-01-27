#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Database connection settings
my $dbname = 'print_jobs_demo';
my $host   = '127.0.0.1';
my $user   = 'brittany';
my $pass   = 'Candy1988';

my $dsn = "DBI:mysql:database=$dbname;host=$host";

my $dbh = DBI->connect($dsn, $user, $pass, {
    RaiseError => 1,
    PrintError => 0,
}) or die "Could not connect: $DBI::errstr";

# -----------------------------
# Validate input
# -----------------------------
my ($job_id, $new_status, $changed_by) = @ARGV;

if (!$job_id || !$new_status) {
    die "Usage: perl update_job_status.pl <job_id> <new_status> [changed_by]\n";
}

$changed_by ||= 'system';  # default if not provided

# -----------------------------
# Fetch current status
# -----------------------------
my $current_status_sql = q{
    SELECT status FROM jobs WHERE id = ?
};

my $sth = $dbh->prepare($current_status_sql);
$sth->execute($job_id);

my ($old_status) = $sth->fetchrow_array;

if (!defined $old_status) {
    die "Job ID $job_id not found.\n";
}

# -----------------------------
# Update the job status
# -----------------------------
my $update_sql = q{
    UPDATE jobs SET status = ? WHERE id = ?
};

my $update_sth = $dbh->prepare($update_sql);
$update_sth->execute($new_status, $job_id);

# -----------------------------
# Insert into job_status_history
# -----------------------------
my $history_sql = q{
    INSERT INTO job_status_history (job_id, status, changed_by)
VALUES (?, ?, ?)

};

my $history_sth = $dbh->prepare($history_sql);
$history_sth->execute($job_id, $new_status, $changed_by);

# -----------------------------
# Output confirmation
# -----------------------------
print "Job $job_id status updated:\n";
print "  Old Status: $old_status\n";
print "  New Status: $new_status\n";
print "  Changed By: $changed_by\n";
print "Status history recorded successfully.\n";

# Cleanup
$sth->finish;
$update_sth->finish;
$history_sth->finish;
$dbh->disconnect;

