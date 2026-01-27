use strict;
use warnings;
use DBI;

my $dbname = 'print_jobs_demo';
my $host   = '127.0.0.1';
my $user   = 'brittany';
my $pass   = 'Candy1988';

my $dsn = "DBI:mysql:database=$dbname;host=$host";

my $dbh = DBI->connect($dsn, $user, $pass, {
    RaiseError => 1,
    PrintError => 0,
}) or die "Could not connect: $DBI::errstr";

my $sql = q{
    SELECT j.id, j.job_name, j.status, c.name AS customer_name
    FROM jobs j
    JOIN customers c ON j.customer_id = c.id
    ORDER BY j.id
};

my $sth = $dbh->prepare($sql);
$sth->execute();

while (my $row = $sth->fetchrow_hashref) {
    print "Job ID: $row->{id}\n";
    print "  Customer: $row->{customer_name}\n";
    print "  Job Name: $row->{job_name}\n";
    print "  Status: $row->{status}\n";
    print "-------------------------\n";
}

$sth->finish;
$dbh->disconnect;

