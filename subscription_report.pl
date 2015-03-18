#!/usr/bin/perl

use strict;
use POSIX;
use DBI;

# Day of run + domain makes a unique entry
my $day = floor(time() / 60 / 60 / 24);

# Command line option to override the default day of today
#opts, args = getopt.getopt(sys.argv[1:], ":d:", ["day="])

#for opt, arg in opts:
#	if (opt in ['-d', '--day']):
#		day = int(arg)

my $dbh = DBI->connect('dbi:SQLite:subscriptions.db');

my @sorted_top_fifty;
my %domain_counts;

print("Getting subscriptions...");

my $sth = $dbh->prepare('SELECT addr FROM mailing');
$sth->execute();
my $rows = $sth->fetchall_arrayref();
$sth->finish();
# TODO: this loop could be more compact
foreach (@$rows)
{
	# Chop off username and '@' leaving domain only
	my ($user, $domain) = split(/@/, @$_[0]);
	#print("domain=$domain\n");

	# Count occurences of each domain
	if (exists($domain_counts{$domain}))
	{
		$domain_counts{$domain} += 1;
	}
	else
	{
		$domain_counts{$domain} = 1
	}
}

print("done!\n");

print("Updating the daily domain counts...");

# TODO: revisit to attemp to use execute_array instead of looping
# Insert today's count for each domain into daily_domain_counts and overwrite if
# the count is already there for today's run
$sth = $dbh->prepare("INSERT OR REPLACE INTO daily_domain_counts (domain, day, count)
	VALUES (?, ?, ?)");

while (my ($domain, $count) = each %domain_counts)
{
	#print("domain=$domain, count=$count\n");

	$sth->execute($domain, $day, $count);
}

$sth->finish();

print("done!\n");

# Get the top 50 domains by today's count
$sth = $dbh->prepare("SELECT domain, count FROM daily_domain_counts WHERE day = ?
	ORDER BY count DESC LIMIT 50");
$sth->execute($day);
$rows = $sth->fetchall_hashref('domain');
$sth->finish();

while (my ($domain, $count) = each %domain_counts)
{
	#print("domain=$domain, count=$count\n");
	my $thirty_days_ago = $day - 30;

	# Get the count from 30 days ago
	$sth = $dbh->prepare("SELECT count FROM daily_domain_counts
		WHERE day=? AND domain = ? LIMIT 1");
	$sth->execute($day, $domain);	# TODO: PUT thirty_days_ago BACK!
	my @count_thirty_days_ago = $sth->fetchrow_array();
	#print("count_thirty_days_ago[0]=$count_thirty_days_ago[0]n");
	$sth->finish();

	my $percent_increase = "Infinite";
	if (@count_thirty_days_ago)
	{
		my $count_thirty_days_ago = $count_thirty_days_ago[0];
		$percent_increase = 100 * ($count - $count_thirty_days_ago)
			/ $count_thirty_days_ago;
	}
	
	my %domain_dict = (domain => $domain, count => $count,
		percent_increase => $percent_increase,);

	# Put this domain before the first count smaller than the current
	if (@sorted_top_fifty)
	{
		my $i = 0;
#		while (i < $#sorted_top_fifty and \
#			sorted_top_fifty[i]["percent_increase"] > percent_increase):
#			i += 1
#		sorted_top_fifty.insert(i, domain_dict)
	}
	else
	{
		push(@sorted_top_fifty, %domain_dict);
	}
}

print("Domain\t\t| Count\t| % Increase\n");

my $i = 0;
foreach (@sorted_top_fifty)
{
	$i += 1;
	print "$i. $_{'domain'}\t| $_{'count'}\t| $_{'percent_increase'}%\n";
}

$dbh->disconnect();

print("Done!\n");

