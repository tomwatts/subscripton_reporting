#!/usr/bin/perl

use strict;
use DBI;
use Getopt::Long;
use POSIX;

my $start_time = time();

# Day of run + domain makes a unique entry
my $day = floor(time() / 60 / 60 / 24);

# Command line option to override the default day of today
GetOptions("day=i" => \$day)
or die("Error occured while getting command line arguments\n");

my $thirty_days_ago = $day - 30;

my $dbh = DBI->connect('dbi:SQLite:subscriptions.db');

my @top_fifty;
my %domain_counts;

print("Getting subscriptions...");

my $sth = $dbh->prepare('SELECT addr FROM mailing');
$sth->execute();

while(my @row = $sth->fetchrow_array())
{
	# Chop off username and '@' leaving domain only
	my $domain = (split(/@/, $row[0]))[-1];

	# Count occurences of each domain
	$domain_counts{$domain} += 1;
}

$sth->finish();

print("done!\nUpdating the daily domain counts...");

# Insert today's count for each domain into daily_domain_counts and overwrite if
# the count is already there for today's run
$sth = $dbh->prepare("INSERT OR REPLACE INTO daily_domain_counts (domain, day, count)
	VALUES (?, ?, ?)");

while(my ($domain, $count) = each %domain_counts)
{
	$sth->execute($domain, $day, $count);
}

$sth->finish();

print("done!\n");

# Get the top 50 domains by today's count
$sth = $dbh->prepare("SELECT domain, count
	FROM daily_domain_counts WHERE day = ?
	ORDER BY count DESC LIMIT 50");
$sth->execute($day);

while(my @row = $sth->fetchrow_array())
{
	my $domain = $row[0];
	my $count = $row[1];

	# Get the count from 30 days ago
	my $previous_count_sth = $dbh->prepare(
		"SELECT count FROM daily_domain_counts
		WHERE day=? AND domain = ? LIMIT 1");
	$previous_count_sth->execute($thirty_days_ago, $domain);
	my @count_thirty_days_ago = $previous_count_sth->fetchrow_array();
	$previous_count_sth->finish();

	my $percent_increase = "inf";
	if(@count_thirty_days_ago)
	{
		$percent_increase = 100 * ($count - $count_thirty_days_ago[0])
			/ $count_thirty_days_ago[0];
	}
	
	push(@top_fifty, {domain => $domain, count => $count,
		percent_increase => $percent_increase});
}

$sth->finish();

@top_fifty =
	sort({ $b->{'percent_increase'} <=> $a->{'percent_increase'} } @top_fifty);

print("Domain\t\t| Count\t| % Increase\n");

my $i;
foreach(@top_fifty)
{
	$i += 1;
	printf("$i. $_->{'domain'}\t| $_->{'count'}\t| %.0f%\n",
		$_->{'percent_increase'});
}

$dbh->disconnect();

print("Done!\n");

my $run_time = time() - $start_time;
print("Elapsed time: $run_time s\n");

